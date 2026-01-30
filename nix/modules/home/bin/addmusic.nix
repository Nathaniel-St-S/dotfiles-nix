{ pkgs, ... }:

let
  addmusic = pkgs.writeShellScriptBin "addmusic" ''
    # Music file management for Navidrome with smart track numbering
    # Usage: 
    #   Album:   ./add_music.sh --album "Artist" "Album" [YEAR] file1.flac file2.mp3 ...
    #   Single:  ./add_music.sh --single "Artist" file.mp3 [file2.mp3 ...]
    #   Compilation: ./add_music.sh --compilation "Album Name" [YEAR] file1.mp3 file2.flac ...
    REMOTE_DIR="/srv/media/music"
    SERVER="nathaniels@homeserver"
    show_usage() {
        echo "Usage:"
        echo "  Album:        $0 --album \"Artist\" \"Album\" [YEAR] file1.flac file2.mp3 ..."
        echo "  Single:       $0 --single \"Artist\" file1.mp3 [file2.mp3 ...]"
        echo "  Compilation:  $0 --compilation \"Album Name\" [YEAR] file1.mp3 file2.flac ..."
        echo ""
        echo "Examples:"
        echo "  $0 --album \"Sade\" \"The Best of Sade\" 1994 *.wma"
        echo "  $0 --album \"Drake\" \"Nothing Was the Same\" *.mp3"
        echo "  $0 --single \"Beenie Man\" *.mp3"
        echo "  $0 --compilation \"CONTAGIOUS RIDDIM\" 2013 *.mp3"
        exit 1
    }
    # Check if filename already has proper track number format (01 - Title.ext or 01 Title.ext)
    is_properly_numbered() {
        local filename="$1"
        if [[ "$filename" =~ ^[0-9]{2}[[:space:]\-]+.+ ]]; then
            return 0
        fi
        return 1
    }
    # Extract track number from audio metadata using ffprobe
    get_metadata_track_number() {
        local filepath="$1"
        local track_num=""
        
        if command -v ffprobe &> /dev/null; then
            track_num=$(ffprobe -v quiet -show_entries format_tags=track -of default=noprint_wrappers=1:nokey=1 "$filepath" 2>/dev/null)
            
            # Sometimes track is stored as "track/total", extract just the track number
            track_num="''${track_num%%/*}"
            
            # Remove any whitespace
            track_num=$(echo "$track_num" | tr -d '[:space:]')
            
            if [[ "$track_num" =~ ^[0-9]+$ ]]; then
                printf "%02d" "$track_num"
                return 0
            fi
        fi
        
        return 1
    }
    # Get track title from metadata
    get_metadata_title() {
        local filepath="$1"
        local title=""
        
        if command -v ffprobe &> /dev/null; then
            title=$(ffprobe -v quiet -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$filepath" 2>/dev/null)
            if [[ -n "$title" ]]; then
                echo "$title"
                return 0
            fi
        fi
        
        return 1
    }
    # Sanitize filename by replacing invalid characters
    sanitize_filename() {
        local name="$1"
        # Replace forward slashes with dashes (they can't exist in filenames)
        name="''${name//\//-}"
        # Replace backslashes with dashes
        name="''${name//\\/-}"
        echo "$name"
    }
    # Determine the proper filename for a track
    determine_filename() {
        local filepath="$1"
        local fallback_number="$2"
        local filename=$(basename "$filepath")
        local extension="''${filename##*.}"
        local basename_no_ext="''${filename%.*}"
        
        # Strategy 1: Check if already properly numbered
        if is_properly_numbered "$filename"; then
            sanitize_filename "$filename"
            return 0
        fi
        
        # Strategy 2: Try to get track number and title from metadata
        local track_num=$(get_metadata_track_number "$filepath")
        local track_title=$(get_metadata_title "$filepath")
        
        if [[ -n "$track_num" && -n "$track_title" ]]; then
            sanitize_filename "''${track_num} - ''${track_title}.''${extension}"
            return 0
        elif [[ -n "$track_num" ]]; then
            # Have track number but no title, use original filename
            sanitize_filename "''${track_num} - ''${basename_no_ext}.''${extension}"
            return 0
        fi
        
        # Strategy 3: Fallback - prepend sequential number to original filename
        sanitize_filename "''${fallback_number} - ''${filename}"
        return 0
    }
    if (( $# < 3 )); then
        show_usage
    fi
    MODE="$1"
    shift
    case "$MODE" in
        --album)
            ARTIST="$1"
            ALBUM="$2"
            shift 2
            
            # Check if next argument is a year (4 digits)
            YEAR=""
            if [[ "$1" =~ ^[0-9]{4}$ ]]; then
                YEAR="$1"
                shift
            fi
            
            if [[ -z "$ARTIST" || -z "$ALBUM" || $# -eq 0 ]]; then
                echo "Error: --album requires Artist, Album, and at least one file"
                show_usage
            fi
            
            # Format album name with year if provided
            if [[ -n "$YEAR" ]]; then
                ALBUM_DIR="$ALBUM ($YEAR)"
            else
                ALBUM_DIR="$ALBUM"
            fi
            
            TARGET_DIR="$REMOTE_DIR/$ARTIST/$ALBUM_DIR"
            echo "============================================"
            echo "Adding Album: $ALBUM_DIR"
            echo "Artist: $ARTIST"
            echo "Files: $#"
            echo "============================================"
            ;;
            
        --single)
            ARTIST="$1"
            shift
            
            if [[ -z "$ARTIST" || $# -eq 0 ]]; then
                echo "Error: --single requires Artist and at least one file"
                show_usage
            fi
            
            TARGET_DIR="$REMOTE_DIR/$ARTIST/Singles"
            echo "============================================"
            echo "Adding Singles"
            echo "Artist: $ARTIST"
            echo "Files: $#"
            echo "============================================"
            ;;
            
        --compilation)
            ALBUM="$1"
            shift
            
            # Check if next argument is a year (4 digits)
            YEAR=""
            if [[ "$1" =~ ^[0-9]{4}$ ]]; then
                YEAR="$1"
                shift
            fi
            
            if [[ -z "$ALBUM" || $# -eq 0 ]]; then
                echo "Error: --compilation requires Album Name and at least one file"
                show_usage
            fi
            
            # Format album name with year if provided
            if [[ -n "$YEAR" ]]; then
                ALBUM_DIR="$ALBUM ($YEAR)"
            else
                ALBUM_DIR="$ALBUM"
            fi
            
            TARGET_DIR="$REMOTE_DIR/Various Artists/$ALBUM_DIR"
            echo "============================================"
            echo "Adding Compilation: $ALBUM_DIR"
            echo "Files: $#"
            echo "============================================"
            ;;
            
        *)
            echo "Error: Unknown mode '$MODE'"
            show_usage
            ;;
    esac
    # Check for ffprobe
    if ! command -v ffprobe &> /dev/null; then
        echo "⚠️  Warning: ffprobe not found. Install ffmpeg for metadata reading."
        echo "   Falling back to sequential numbering only."
        echo ""
    fi
    # Create remote directory
    if ! ssh "$SERVER" "mkdir -p \"$TARGET_DIR\""; then
        echo "❌ ERROR: Failed to create remote directory: $TARGET_DIR"
        exit 1
    fi
    echo "✓ Remote directory ready"
    echo ""
    # Build array of files with their determined names
    declare -a FILE_MAPPINGS
    FALLBACK_NUM=1
    for FILE_PATH in "$@"; do
        if [[ ! -f "$FILE_PATH" ]]; then
            echo "❌ File not found: $FILE_PATH"
            continue
        fi
        
        FALLBACK_NUMBER=$(printf "%02d" $FALLBACK_NUM)
        NEW_NAME=$(determine_filename "$FILE_PATH" "$FALLBACK_NUMBER")
        
        FILE_MAPPINGS+=("$FILE_PATH|$NEW_NAME")
        ((FALLBACK_NUM++))
    done
    # Sort by the new filenames to ensure proper track order
    IFS=$'\n' FILE_MAPPINGS=($(sort -t'|' -k2 <<<"''${FILE_MAPPINGS[*]}"))
    unset IFS
    # Process each file
    SUCCESS=0
    FAILED=0
    for MAPPING in "''${FILE_MAPPINGS[@]}"; do
        FILE_PATH="''${MAPPING%%|*}"
        NEW_NAME="''${MAPPING##*|}"
        ORIGINAL_NAME=$(basename "$FILE_PATH")
        
        if [[ "$ORIGINAL_NAME" != "$NEW_NAME" ]]; then
            echo "Copying: $ORIGINAL_NAME"
            echo "      → $NEW_NAME"
        else
            echo "Copying: $NEW_NAME"
        fi
        
        # Escape only the problematic characters for shell globbing
        SAFE_PATH="$TARGET_DIR/$NEW_NAME"
        SAFE_PATH="''${SAFE_PATH//\[/\\[}"  # Escape [
        SAFE_PATH="''${SAFE_PATH//\]/\\]}"  # Escape ]
        SAFE_PATH="''${SAFE_PATH//\*/\\*}"  # Escape *
        SAFE_PATH="''${SAFE_PATH//\?/\\?}"  # Escape ?
        
        if rsync -aPvh "$FILE_PATH" "$SERVER:$SAFE_PATH"; then
            echo "✓ Success"
            ((SUCCESS++))
        else
            echo "❌ Failed"
            ((FAILED++))
        fi
        echo ""
    done
    echo "============================================"
    echo "Summary:"
    echo "  ✓ Successful: $SUCCESS"
    if (( FAILED > 0 )); then
        echo "  ❌ Failed: $FAILED"
    fi
    echo "  Target: $TARGET_DIR"
    echo "============================================"
  '';
in
{
  home.packages = [
    addmusic
  ];
}
