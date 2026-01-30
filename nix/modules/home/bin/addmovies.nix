{ pkgs, ... }:

let 
  addmovies = pkgs.writeShellScriptBin "addmovies" ''
    # Multiple movie support with automatic subtitle detection
    # Usage: ./add_movie.sh "path/to/Movie.mkv" YEAR "path/to/Next_Movie.mp4" YEAR ...
    
    if (( $# % 2 != 0 )); then
        echo "Error: arguments must come in pairs: Movie_File YEAR"
        exit 1
    fi
    
    LOCAL_DIR="$HOME/Videos/Movies"
    REMOTE_DIR="/srv/media/movies"
    SERVER="nathaniels@homeserver"
    
    while (( $# )); do
        MOVIE_PATH="$1"
        YEAR="$2"
        shift 2
        
        # Extract filename and extension
        MOVIE_FILE=$(basename "$MOVIE_PATH")
        MOVIE_EXT="''${MOVIE_FILE##*.}"
        MOVIE_NAME="''${MOVIE_FILE%.*}"
        
        FOLDER_NAME="''${MOVIE_NAME} (''${YEAR})"
        
        echo "--------------------------------------------"
        echo "Processing: $FOLDER_NAME"
        echo "--------------------------------------------"
        
        # Create remote directory
        if ! ssh "$SERVER" "mkdir -p \"$REMOTE_DIR/$FOLDER_NAME\""; then
            echo "❌ ERROR: Failed to create remote directory"
            continue
        fi
        
        # Rsync movie
        if [[ -f "$MOVIE_PATH" ]]; then
            if rsync -aPvh \
                "$MOVIE_PATH" \
                "$SERVER:$REMOTE_DIR/$FOLDER_NAME/$FOLDER_NAME.$MOVIE_EXT"; then
                echo "✓ Movie copied (.$MOVIE_EXT)"
            else
                echo "❌ ERROR: Failed to copy movie"
                continue
            fi
        else
            echo "❌ ERROR: Movie file not found: $MOVIE_PATH"
            continue
        fi
        
        # Find and rsync all matching subtitle files
        MOVIE_DIR=$(dirname "$MOVIE_PATH")
        SUBTITLE_COUNT=0
        
        # Use find to locate all .srt files that start with the movie name
        while IFS= read -r -d ''' SUB_PATH; do
            if [[ -f "$SUB_PATH" ]]; then
                SUB_FILE=$(basename "$SUB_PATH")
                # Extract the suffix after the movie name (e.g., ".en_us.srt", ".es.srt", ".srt")
                SUB_SUFFIX="''${SUB_FILE#$MOVIE_NAME}"
                
                # Target filename uses folder name instead of original movie name
                TARGET_SUB="''${FOLDER_NAME}''${SUB_SUFFIX}"
                
                if rsync -aPvh \
                    "$SUB_PATH" \
                    "$SERVER:$REMOTE_DIR/$FOLDER_NAME/$TARGET_SUB"; then
                    echo "✓ Subtitle copied: $SUB_FILE"
                    ((SUBTITLE_COUNT++))
                else
                    echo "⚠ Subtitle copy failed: $SUB_FILE"
                fi
            fi
        done < <(find "$MOVIE_DIR" -maxdepth 1 -type f -name "''${MOVIE_NAME}*.srt" -print0)
        
        if (( SUBTITLE_COUNT == 0 )); then
            echo "⚠ No subtitles found"
        fi
        
        echo "✓ Done with $FOLDER_NAME"
    done
    
    echo "--------------------------------------------"
    echo "All movies processed."
    echo "--------------------------------------------"
  '';

in
{
  home.packages = [
    addmovies
  ];
}
