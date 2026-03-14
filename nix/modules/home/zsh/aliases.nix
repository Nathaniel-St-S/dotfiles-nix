{ ... }:{
  programs.zsh.shellGlobalAliases = {
    NE  = "2>/dev/null";
    DN  = "> /dev/null";
    NUL = ">/dev/null 2>&1";
    JQ  = "| jq";
    CB  = "| wl-copy";
    C   = "| column";
    G   = "| grep";
    L   = "| less";
    M   = "| more";
    T   = "| tee";
  };

  programs.zsh.shellAliases = {
    # System 
    switch    = "nh os switch";
    test      = "nh os test";
    rollback  = "nh os rollback";
    gcollect  = "nh clean all --keep-since 7d --keep 3";
    gcollectd = "nh clean all --nogcroots";
    flakeup   = "nix flake update";
    optimize  = "sudo nix-store --optimize";

    # Misc
    mkdir  = "mkdir -p -v";
    path   = "echo -e \${PATH//:/\\\\n}";
    sudo   = "sudo ";
    please = "sudo";

    # Disk and memory usage
    du = "du -h";
    df = "df -h";
    meminfo = "free -h -m -l -t";
    lsize = "du -hs .[^.]* | sort -rh";

    # Safety
    mv = "mv -i -v";
    cp = "cp -i -v";
    ln = "ln -i -v";
    chown = "chown --preserve-root";
    chmod = "chmod --preserve-root";
    chgrp = "chgrp --preserve-root";
    rm = "rm -I -v --preserve-root";

    # Cat aliases
    cat = "bat --style=plain -P --color=always";
    bat = "bat --style=numbers,changes --color=always";

    # cd aliases
    home = "cd ~";
    last = "cd -";
    "cd.." = "cd ..";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    # ls aliases
    ls = "ls -aFh --color=always --group-directories-first";
    lc = "ls -ltcrh";
    lu = "ls -lturh";
    lt = "ls -ltrh";
    ll = "ls -Fls";
    lf = "ls -l |grep -E -v '^d'";
    ldir = "ls -l |grep -E '^d'";

    #Tmux Aliases
    tm  = "tmux";
    tls = "tmux ls";
    ta  = "tmux attach";
    tmuxn = "tmux set-option -g default-shell $(command -v nu) \\; new-session nu";

    # Tree aliases
    tree  = "tree -aCAhFl -I .git/ --dirsfirst -L 3";
    treed = "tree -CAFd";

    # Search command line history
    h = "history | grep ";
    p = "ps aux | grep ";
    f = "find . | grep";

    # Git aliases
    gs  = "git status --short";
    gsh = "git show";
    gcp = "git cherry-pick";
    gd  = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
    gdt = "git difftool";
    ga  = "git add";
    gc  = "git commit";
    gp  = "git push";
    gu  = "git pull";
    gl  = "git log --graph --date=format:\"%d/%m/%y\" --pretty=format:\"%C(yellow)%h%Creset %C(white)%ad%Creset %C(bold)%s %C(bold green)%D%Creset%n\"";
    gb  = "git branch";
    gi  = "git init";
    gw  = "git switch";
    go  = "git checkout";

    # System
    x = "exit";
    halt = "sudo halt";
    reboot = "sudo reboot";
    shutdown = "sudo shutdown";
    poweroff = "sudo poweroff";
  };
}
