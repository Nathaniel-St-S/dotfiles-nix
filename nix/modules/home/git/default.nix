{ pkgs, username, ... }:

{
  home.packages = with pkgs; [ wget curl difftastic];

  home.file.".config/git/allowed_signers".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiXoh2BrTzjZZLCbyCMEOC0qBLs54hd6y4v4lIxfolU savoury.nathaniel@gmail.com
  '';

  programs.git = {
    enable = true;

    signing = {
      key = "/home/${username}/.ssh/id_ed25519";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Nathaniel-St-S";
        email = "savoury.nathaniel@gmail.com";
      };

      init.defaultBranch = "master";

      core = {
        compression = 9;
        whitespace = "error";
        preloadindex = true;
      };

      push = {
        default = "current";
        autoSetupRemote = true;
        followTags = true;
      };

      pull = {
        default = "current";
        rebase = true;
      };

      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };

      branch.sort = "-committerdate";
      tag.sort = "-taggerdate";

      status = {
        branch = true;
        showStash = true;
        showUntrackedFiles = "all";
      };

      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
        external = "difft";
        tool = "nvimdiff";
      };

      difftool = {
        prompt = false;
      };

      "difftool \"nvimdiff\"" = {
        cmd = ''nvim -d "$REMOTE" "$LOCAL"'';
      };

      gpg = {
        format = "ssh";
        "ssh".allowedSignersFile = "/home/${username}/.config/git/allowed_signers";
      };

      alias = {
        dl = "-c diff.external=difft log -p --ext-diff";
        ds = "-c diff.external=difft show --ext-diff";
        count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
        diffs = "!git log --graph --decorate --color=always --pretty=format:'%h %C(auto)%d%Creset %s %Cgreen(%cr)%Creset %Cblue[%an]' | awk '{ for(i=1; i<=NF; i++) { if(''$i ~ /^[0-9a-f]{7,}''$/) { print ''$i \"\\t\" ''$0; break } } }' | fzf --ansi --reverse --delimiter=''$'\\t' --with-nth=2.. --preview 'git --no-pager show --color=always {1}' --preview-window=right:50%";
        browse = "!git log --graph --decorate --color=always --pretty=format:'%h %C(auto)%d%Creset %s %Cgreen(%cr)%Creset %Cblue[%an]' | awk '{ for(i=1; i<=NF; i++) { if(''$i ~ /^[0-9a-f]{7,}''$/) { print ''$i \"\\t\" ''$0; break } } }' | fzf --ansi --reverse --delimiter=''$'\\t' --with-nth=2.. --preview 'git --no-pager show --color=always {1}' --preview-window=right:70% --bind 'enter:execute(git checkout {1})+abort'";
      };
    };
  };
}

