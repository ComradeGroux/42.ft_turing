BOLD	:= \033[1m
GRAY	:= \033[90m
GREEN	:= \033[32m
BLUE	:= \033[34m
RESET	:= \033[0m
ERASE	:= \r\033[2K

NAME = ft_turing

CAMLOPT = ocamlopt
CAMLC = ocamlc
CAMLDEP = ocamldep
DEP_FILE_OPT = $(BUILD_DIR)/$(OPT_DIR)/.depend
DEP_FILE_BYT = $(BUILD_DIR)/$(BYT_DIR)/.depend

SRCS_DIR = src
BUILD_DIR = build
OPT_DIR = opt
BYT_DIR = byt

SOURCES =	main.ml		\
			parser.ml
SRCS = $(filter %.ml, $(addprefix $(SRCS_DIR)/, $(SOURCES)))
MLI_SRCS = $(filter %.mli, $(addprefix $(SRCS_DIR)/, $(SOURCES)))

ORDER_FILE_OPT = $(BUILD_DIR)/$(OPT_DIR)/.order
ORDER_FILE_BYT = $(BUILD_DIR)/$(BYT_DIR)/.order


all: $(BUILD_DIR) $(DEP_FILE_OPT) $(DEP_FILE_BYT) opt byt $(NAME)


$(ORDER_FILE_OPT): $(SRCS) $(MLI_SRCS) | $(BUILD_DIR)
	@echo "SORTED_SRCS_OPT := $(shell $(CAMLDEP) -sort -I $(SRCS_DIR) $(SRCS) $(MLI_SRCS))" > $(ORDER_FILE_OPT)
-include $(ORDER_FILE_OPT)

$(ORDER_FILE_BYT): $(SRCS) $(MLI_SRCS) | $(BUILD_DIR)
	@echo "SORTED_SRCS_BYT := $(shell $(CAMLDEP) -sort -I $(SRCS_DIR) $(SRCS) $(MLI_SRCS))" > $(ORDER_FILE_BYT)
-include $(ORDER_FILE_BYT)

OPTOBJS = $(patsubst $(SRCS_DIR)/%.ml, $(BUILD_DIR)/$(OPT_DIR)/%.cmx, $(filter %.ml, $(SORTED_SRCS_OPT)))
BYTOBJS = $(patsubst $(SRCS_DIR)/%.ml, $(BUILD_DIR)/$(BYT_DIR)/%.cmo, $(filter %.ml, $(SORTED_SRCS_BYT)))

FLAGS_OPT = -I $(BUILD_DIR)/$(OPT_DIR)
FLAGS_BYT = -I $(BUILD_DIR)/$(BYT_DIR)


$(DEP_FILE_OPT): $(SRCS) $(MLI_SRCS) | $(BUILD_DIR)
	@$(CAMLDEP) -I $(SRCS_DIR) $(SRCS) $(MLI_SRCS) | sed 's|$(SRCS_DIR)/\([^ ]*\)\.cmo|$(BUILD_DIR)/$(OPT_DIR)/\1.cmo|g; s|$(SRCS_DIR)/\([^ ]*\)\.cmx|$(BUILD_DIR)/$(OPT_DIR)/\1.cmx|g; s|$(SRCS_DIR)/\([^ ]*\)\.cmi|$(BUILD_DIR)/$(OPT_DIR)/\1.cmi|g' > $(DEP_FILE_OPT)
-include $(DEP_FILE_OPT)

$(DEP_FILE_BYT): $(SRCS) $(MLI_SRCS) | $(BUILD_DIR)
	@$(CAMLDEP) -I $(SRCS_DIR) $(SRCS) $(MLI_SRCS) | sed 's|$(SRCS_DIR)/\([^ ]*\)\.cmo|$(BUILD_DIR)/$(BYT_DIR)/\1.cmo|g; s|$(SRCS_DIR)/\([^ ]*\)\.cmx|$(BUILD_DIR)/$(BYT_DIR)/\1.cmx|g; s|$(SRCS_DIR)/\([^ ]*\)\.cmi|$(BUILD_DIR)/$(BYT_DIR)/\1.cmi|g' > $(DEP_FILE_BYT)
-include $(DEP_FILE_BYT)


$(NAME):
	@[ -L $(NAME) ] || \
	 (printf "\n$(BOLD)$(BLUE)Creating the symbolic link$(RESET)\n" && \
	  printf "$(GRAY)  Creating symlink $(NAME) -> $(NAME).opt...$(RESET)" && \
	  ln -s $(NAME).opt $(NAME) && \
	  printf "$(ERASE)$(GREEN)  ✓ $(NAME) -> $(NAME).opt$(RESET)\n")

opt: $(NAME).opt
byt: $(NAME).byt

$(BUILD_DIR)/.opt_start: $(SRCS) $(MLI_SRCS) | $(BUILD_DIR)
	@printf "$(BOLD)$(BLUE)Compiling $(NAME).opt$(RESET)\n"
	@touch $@

$(BUILD_DIR)/.byt_start: $(SRCS) $(MLI_SRCS) | $(BUILD_DIR)
	@printf "\n$(BOLD)$(BLUE)Compiling $(NAME).byt$(RESET)\n"
	@touch $@

$(NAME).opt: $(OPTOBJS)
	@printf "$(BOLD)Linking $(NAME).opt$(RESET)\n"
	@$(CAMLOPT) $(FLAGS_OPT) -o $@ $^
	@printf "$(GREEN)  ✓ $(NAME).opt ready$(RESET)\n"

$(BUILD_DIR)/$(OPT_DIR)/%.cmi: $(SRCS_DIR)/%.mli | $(BUILD_DIR)/.opt_start
	@printf "$(GRAY)  $<...$(RESET)" && \
	 $(CAMLOPT) $(FLAGS_OPT) -c -o $@ $< && \
	 printf "$(ERASE)$(GREEN)  ✓ $<$(RESET)\n"

$(BUILD_DIR)/$(OPT_DIR)/%.cmx: $(SRCS_DIR)/%.ml | $(BUILD_DIR)/.opt_start
	@printf "$(GRAY)  $<...$(RESET)" && \
	 $(CAMLOPT) $(FLAGS_OPT) -c -o $@ $< && \
	 printf "$(ERASE)$(GREEN)  ✓ $<$(RESET)\n"

$(NAME).byt: $(BYTOBJS)
	@printf "$(BOLD)Linking $(NAME).byt$(RESET)\n"
	@$(CAMLC) $(FLAGS_BYT) -o $@ $^
	@printf "$(GREEN)  ✓ $(NAME).byt ready$(RESET)\n"

$(BUILD_DIR)/$(BYT_DIR)/%.cmi: $(SRCS_DIR)/%.mli | $(BUILD_DIR)/.byt_start
	@printf "$(GRAY)  $<...$(RESET)" && \
	 $(CAMLC) $(FLAGS_BYT) -c -o $@ $< && \
	 printf "$(ERASE)$(GREEN)  ✓ $<$(RESET)\n"

$(BUILD_DIR)/$(BYT_DIR)/%.cmo: $(SRCS_DIR)/%.ml | $(BUILD_DIR)/.byt_start
	@printf "$(GRAY)  $<...$(RESET)" && \
	 $(CAMLC) $(FLAGS_BYT) -c -o $@ $< && \
	 printf "$(ERASE)$(GREEN)  ✓ $<$(RESET)\n"

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/$(OPT_DIR)
	@mkdir -p $(BUILD_DIR)/$(BYT_DIR)

clean:
	@printf "$(BOLD)$(BLUE)Cleaning $(NAME) objects...$(RESET)\n"
	@printf "$(GRAY)  Removing $(BUILD_DIR)...$(RESET)" && \
	 rm -rf $(BUILD_DIR) && \
	 printf "$(ERASE)"
	@printf "$(GREEN)  ✓ Build files cleaned$(RESET)\n"

fclean: clean
	@printf "$(GRAY)  Removing $(NAME)...$(RESET)" && \
	 rm -f $(NAME) && \
	 printf "$(ERASE)"
	@printf "$(GREEN)  ✓ $(NAME) cleaned$(RESET)\n"
	@printf "$(GRAY)  Removing $(NAME).opt...$(RESET)" && \
	 rm -f $(NAME).opt && \
	 printf "$(ERASE)"
	@printf "$(GREEN)  ✓ $(NAME).opt cleaned$(RESET)\n"
	@printf "$(GRAY)  Removing $(NAME).byt...$(RESET)" && \
	 rm -f $(NAME).byt && \
	 printf "$(ERASE)"
	@printf "$(GREEN)  ✓ $(NAME).byt cleaned$(RESET)\n"

re: fclean
	@$(MAKE) --no-print-directory

.PHONY: all clean fclean re opt byt
