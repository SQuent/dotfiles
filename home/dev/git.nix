{ ... }:
# Git identity (name/email per github/gitlab/work/nas context) is set
# dynamically via fnox-exported env vars.
{
  programs.git.enable = true;

  programs.zsh.shellAliases = {
    g = "git";
    gs = "git status";
    ga = "git add";
    gaa = "git add .";
    grm = "git rm";
    gc = "git commit";
    gps = "git push";
    gpl = "git pull";
    gf = "git fetch";
    grb = "git rebase";
    grba = "git rebase --abort";
    grbc = "git rebase --continue";
    gm = "git merge";
    gi = "git init";
    gcl = "git clone";
    gch = "git checkout";
    gb = "git branch";
    gd = "git diff";
    gtree = "git log --graph --oneline --decorate --abbrev-commit";
    gl = "git log";
    wip = ''git add .; git commit -m "wip"; git push'';
    pc = "pre-commit run --all-files";
  };
}
