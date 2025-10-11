{ config, pkgs, ... }: {
  home.stateVersion = "25.05";

  # programs.neovim = {
  #   enable = true;
  #   plugins = [
  #     pkgs.vimPlugins.nvim-treesitter.withAllGrammars
  #   ];
  #   extraLuaConfig = ''
  #     vim.opt.runtimepath = vim.opt.runtimepath + "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}"
  #     vim.cmd.luafile('${config.home.homeDirectory}/.config/nvim/main.lua')
  #   '';
  # };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
}
