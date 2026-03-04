{ pkgs, ... }:

let
  # Script to generate colors for btop
  btop-generate-colors = pkgs.writeShellScriptBin "btop-generate-colors" /* bash */ ''
    source "$HOME/.cache/wal/colors.sh"

    mkdir -p "$HOME/.config/btop/themes"

    cat > "$HOME/.config/btop/themes/dynamic.theme" << EOF
    # Theme: Pywal Dynamic
    # Automatically generated from pywal colors

    theme[main_bg]="''${background}"
    theme[main_fg]="''${foreground}"
    theme[title]="''${color7}"
    theme[hi_fg]="''${color4}"
    theme[selected_bg]="''${color1}"
    theme[selected_fg]="''${foreground}"
    theme[inactive_fg]="''${color8}"
    theme[proc_misc]="''${color4}"
    theme[cpu_box]="''${color8}"
    theme[mem_box]="''${color8}"
    theme[net_box]="''${color8}"
    theme[proc_box]="''${color8}"
    theme[div_line]="''${color8}"
    theme[temp_start]="''${color2}"
    theme[temp_mid]="''${color3}"
    theme[temp_end]="''${color1}"
    theme[cpu_start]="''${color2}"
    theme[cpu_mid]="''${color3}"
    theme[cpu_end]="''${color1}"
    theme[free_start]="''${color2}"
    theme[free_mid]="''${color3}"
    theme[free_end]="''${color1}"
    theme[cached_start]="''${color2}"
    theme[cached_mid]="''${color3}"
    theme[cached_end]="''${color1}"
    theme[available_start]="''${color2}"
    theme[available_mid]="''${color3}"
    theme[available_end]="''${color1}"
    theme[used_start]="''${color2}"
    theme[used_mid]="''${color3}"
    theme[used_end]="''${color1}"
    theme[download_start]="''${color2}"
    theme[download_mid]="''${color3}"
    theme[download_end]="''${color1}"
    theme[upload_start]="''${color2}"
    theme[upload_mid]="''${color3}"
    theme[upload_end]="''${color1}"
    EOF
  '';
in
{
  home.packages = with pkgs; [ btop btop-generate-colors ];

  programs.btop = {
    enable = true;

    settings = {
      color_theme       = "dynamic.theme";
      theme_background  = false;
      truecolor         = true;
      force_tty         = false;
      presets           = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      vim_keys          = true;
      rounded_corners   = true;
      terminal_sync     = true;
      graph_symbol      = "braille";
      graph_symbol_cpu  = "default";
      graph_symbol_gpu  = "default";
      graph_symbol_mem  = "default";
      graph_symbol_net  = "default";
      graph_symbol_proc = "default";
      shown_boxes       = "cpu mem net proc";
      update_ms         = 2000;

      proc_sorting      = "cpu lazy";
      proc_reversed     = false;
      proc_tree         = false;
      proc_colors       = true;
      proc_gradient     = true;
      proc_per_core     = false;
      proc_mem_bytes    = true;
      proc_cpu_graphs   = true;
      proc_info_smaps   = false;
      proc_left         = false;
      proc_filter_kernel = false;
      proc_aggregate    = false;
      keep_dead_proc_usage = false;

      cpu_graph_upper   = "Auto";
      cpu_graph_lower   = "Auto";
      show_gpu_info     = "Auto";
      cpu_invert_lower  = true;
      cpu_single_graph  = false;
      cpu_bottom        = false;
      show_uptime       = true;
      show_cpu_watts    = true;
      check_temp        = true;
      cpu_sensor        = "Auto";
      show_coretemp     = true;
      cpu_core_map      = "";
      temp_scale        = "celsius";
      base_10_sizes     = false;
      show_cpu_freq     = true;
      freq_mode         = "first";
      clock_format      = "%X";
      background_update = true;
      custom_cpu_name   = "";

      disks_filter      = "";
      mem_graphs        = true;
      mem_below_net     = false;
      zfs_arc_cached    = true;
      show_swap         = true;
      swap_disk         = true;
      show_disks        = true;
      only_physical     = true;
      use_fstab         = true;
      zfs_hide_datasets = false;
      disk_free_priv    = false;
      show_io_stat      = true;
      io_mode           = false;
      io_graph_combined = false;
      io_graph_speeds   = "";

      net_download      = 100;
      net_upload        = 100;
      net_auto          = true;
      net_sync          = true;
      net_iface         = "";
      base_10_bitrate   = "Auto";

      show_battery      = true;
      selected_battery  = "Auto";
      show_battery_watts = true;

      log_level         = "WARNING";
      save_config_on_exit = true;

      nvml_measure_pcie_speeds = true;
      rsmi_measure_pcie_speeds = true;
      gpu_mirror_graph  = true;
      shown_gpus        = "nvidia amd intel";
    };
  };
}
