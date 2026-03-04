{ ... }:{
  programs.nushell.shellAliases = {
    # Misc
    wget = ''wget -c --hsts-file=($env.XDG_DATA_HOME | path join "wget-hsts")'';
    grep = "grep -i --color=always";
    diff = "diff --color=always";
    mkdir = "mkdir -v";
    xopen = "xdg-open";
    please = "sudo";

    # Disk and memory usage";
    df = "df -h";
    meminfo = "free -h -m -l -t";

    # Safety";
    mv = "mv -i -v";
    cp = "cp -i -v";
    ln = "ln -i -v";
    chown = "chown --preserve-root";
    chmod = "chmod --preserve-root";
    chgrp = "chgrp --preserve-root";
    rm = "rm -I -v";

    # CD aliases";
    home = "cd ~";
    last = "cd -";

    # LS aliases";
    ls  = "ls -as";
    lr  = "ls -a **/*";
    lls = "ls -la";

    # Tree aliases";
    tree  = "tree -aCAFl -I .git/ --dirsfirst -L 3";
    treed = "tree -CAFd";

    # System";
    switch    = "nh os switch";
    test      = "nh os test";
    rollback  = "nh os rollback";
    gcollect  = "nh clean all --keep-since 7d --keep 3";
    gcollectd = "nh clean all --nogcroots";
    flakeup   = "sudo nix flake update";
    optimize  = "sudo nix-store --optimize";

    x         = "exit";
    halt      = "sudo halt";
    reboot    = "sudo reboot";
    shutdown  = "sudo shutdown";
    poweroff  = "sudo poweroff";
    systemctl = "sudo systemctl";

    # Tmux aliases";
    tm    = "tmux";
    tls   = "tmux ls";
    ta    = "tmux attach";
    tmuxn = "tmux set-option -g default-shell (which nu | get path.0) ';' new-session nu";

    # Git aliases";
    gs  = "git status --short";
    gsh = "git show";
    gcp = "git cherry-pick";
    gd  = ''git diff --output-indicator-new=" " --output-indicator-old=" "'';
    gdt = "git difftool";
    ga  = "git add";
    gc  = "git commit";
    gp  = "git push";
    gu  = "git pull";
    gl  = ''^git log --graph --date=format:"%d/%m/%y" --pretty=format:"%C(yellow)%h%Creset %C(white)%ad%Creset %C(bold)%s %C(bold green)%D%Creset%n"'';
    gb  = "git branch";
    gi  = "git init";
    gw  = "git switch";
    go  = "git checkout";
  };
}
