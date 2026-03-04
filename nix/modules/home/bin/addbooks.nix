{ pkgs, ... }: 

let 
  addbooks = pkgs.writeShellScriptBin "addbooks" /* bash */ ''
    # Book and comic management for Kavita with metadata reading
    # Usage:
    #   Books:  ./add_books.sh --book "Author Name" "Book Title" file.epub [more books...]
    #   Comics: ./add_books.sh --comic "Series Name" "Volume 01" file.cbz [more chapters...]
    #
    # Supported book formats: .epub, .pdf, .mobi, .azw3
    # Supported comic formats: .cbz, .cbr, image folders
    #
    # Structure:
    #   Books:  /srv/media/books/Author Name/Book Title/Book Title.epub
    #   Comics: /srv/media/comics/Series Name/Volume 01/Chapter 001.cbz
    #           /srv/media/comics/Series Name/Volume 01/Chapter 001/001.jpg (image folders preserved)
    
    REMOTE_BOOKS_DIR="/srv/media/books"
    REMOTE_COMICS_DIR="/srv/media/comics"
    SERVER="nathaniels@homeserver"
    
    show_usage() {
        echo "Usage:"
        echo "  Books:   $0 --book \"Author Name\" \"Book Title\" file.epub [\"Author\" \"Title\" file.pdf ...]"
        echo "  Comics:  $0 --comic \"Series Name\" \"Volume 01\" chapter.cbz [\"Series\" \"Volume\" chapter.cbr ...]"
        echo ""
        echo "Supported book formats: .epub, .pdf, .mobi, .azw3"
        echo "Supported comic formats: .cbz, .cbr, image folders"
        echo ""
        echo "Examples:"
        echo "  $0 --book \"Brandon Sanderson\" \"The Way of Kings\" way_of_kings.epub"
        echo "  $0 --comic \"One Piece\" \"Volume 01\" chapter_001.cbz chapter_002.cbr"
        echo "  $0 --comic \"Manga Series\" \"Volume 01\" \"Chapter 001/\" \"Chapter 002/\""
        exit 1
    }
    
    # Check if path is a directory (image folder)
    is_directory() {
        [[ -d "$1" ]]
    }
    
    # Get file extension, returns empty if directory
    get_extension() {
        local path="$1"
        if is_directory "$path"; then
            echo ""
        else
            echo "''${path##*.}"
        fi
    }
    
    # Check if filename already has proper chapter/number format (001.ext or Chapter 001.ext)
    is_properly_numbered() {
        local filename="$1"
        # Match patterns like: 001.cbz, Chapter 001.cbz, Ch. 001.cbz, etc.
        if [[ "$filename" =~ ^([Cc]hapter[[:space:]]?|[Cc]h\.?[[:space:]]?)?[0-9]{3,}(\.|$) ]]; then
            return 0
        fi
        return 1
    }
    
    # Extract chapter/issue number from comic metadata
    get_comic_metadata_number() {
        local filepath="$1"
        local ext=$(get_extension "$filepath")
        local number=""
        
        # CBZ files are ZIP files, check for ComicInfo.xml
        if command -v unzip &> /dev/null && [[ "$ext" == "cbz" ]]; then
            number=$(unzip -p "$filepath" ComicInfo.xml 2>/dev/null | grep -oP '(?<=<Number>)[^<]+' | head -1)
            
            if [[ "$number" =~ ^[0-9]+$ ]]; then
                printf "%03d" "$number"
                return 0
            fi
        fi
        
        # CBR files are RAR files, check for ComicInfo.xml
        if command -v unrar &> /dev/null && [[ "$ext" == "cbr" ]]; then
            number=$(unrar p -inul "$filepath" ComicInfo.xml 2>/dev/null | grep -oP '(?<=<Number>)[^<]+' | head -1)
            
            if [[ "$number" =~ ^[0-9]+$ ]]; then
                printf "%03d" "$number"
                return 0
            fi
        fi
        
        return 1
    }
    
    # Extract book title from EPUB metadata
    get_epub_title() {
        local filepath="$1"
        local ext=$(get_extension "$filepath")
        local title=""
        
        if command -v unzip &> /dev/null && [[ "$ext" == "epub" ]]; then
            # EPUB files are ZIP files with metadata in content.opf or similar
            title=$(unzip -p "$filepath" "*.opf" 2>/dev/null | grep -oP '(?<=<dc:title>)[^<]+' | head -1)
            
            if [[ -n "$title" ]]; then
                echo "$title"
                return 0
            fi
        fi
        
        return 1
    }
    
    # Extract author from EPUB metadata
    get_epub_author() {
        local filepath="$1"
        local ext=$(get_extension "$filepath")
        local author=""
        
        if command -v unzip &> /dev/null && [[ "$ext" == "epub" ]]; then
            author=$(unzip -p "$filepath" "*.opf" 2>/dev/null | grep -oP '(?<=<dc:creator>)[^<]+' | head -1)
            
            if [[ -n "$author" ]]; then
                echo "$author"
                return 0
            fi
        fi
        
        return 1
    }
    
    # Determine the proper filename for a comic chapter
    determine_comic_filename() {
        local filepath="$1"
        local fallback_number="$2"
        local filename=$(basename "$filepath")
        
        if is_directory "$filepath"; then
            # For directories, clean up the name
            local dirname=$(basename "$filepath")
            
            # If already properly numbered, use as-is
            if is_properly_numbered "$dirname"; then
                local num=$(echo "$dirname" | grep -oP '[0-9]{3,}' | head -1)
                if [[ -n "$num" ]]; then
                    printf "Chapter %03d" "$((10#$num))"
                    return 0
                fi
                echo "$dirname"
                return 0
            fi
            
            # Fallback for directories
            echo "Chapter ''${fallback_number}"
            return 0
        fi
        
        local extension=$(get_extension "$filepath")
        local basename_no_ext="''${filename%.*}"
        
        # Strategy 1: Check if already properly numbered
        if is_properly_numbered "$filename"; then
            # Extract just the number part and reformat to ensure consistency
            local num=$(echo "$basename_no_ext" | grep -oP '[0-9]{3,}' | head -1)
            if [[ -n "$num" ]]; then
                printf "Chapter %03d.%s" "$((10#$num))" "$extension"
                return 0
            fi
            echo "$filename"
            return 0
        fi
        
        # Strategy 2: Try to get chapter number from metadata
        local chapter_num=$(get_comic_metadata_number "$filepath")
        
        if [[ -n "$chapter_num" ]]; then
            echo "Chapter ''${chapter_num}.''${extension}"
            return 0
        fi
        
        # Strategy 3: Fallback - use sequential number
        echo "Chapter ''${fallback_number}.''${extension}"
        return 0
    }
    
    if (( $# < 3 )); then
        show_usage
    fi
    
    MODE="$1"
    shift
    
    case "$MODE" in
        --book)
            if (( $# < 3 )); then
                echo "Error: --book requires at least Author, Title, and one file"
                show_usage
            fi
            
            # Check for unzip (needed for EPUB metadata)
            if ! command -v unzip &> /dev/null; then
                echo "⚠️  Warning: unzip not found. Install unzip for EPUB metadata reading."
                echo "   Falling back to provided names only."
                echo ""
            fi
            
            echo "============================================"
            echo "Adding Books"
            echo "============================================"
            echo ""
            
            SUCCESS=0
            FAILED=0
            
            while (( $# >= 3 )); do
                AUTHOR="$1"
                TITLE="$2"
                FILE_PATH="$3"
                shift 3
                
                if [[ ! -f "$FILE_PATH" ]]; then
                    echo "❌ File not found: $FILE_PATH"
                    ((FAILED++))
                    echo ""
                    continue
                fi
                
                FILE_EXT=$(get_extension "$FILE_PATH")
                
                # Try to get metadata if available (currently only works for EPUB)
                META_TITLE=$(get_epub_title "$FILE_PATH")
                META_AUTHOR=$(get_epub_author "$FILE_PATH")
                
                # Use metadata if found, otherwise use provided values
                FINAL_TITLE="''${META_TITLE:-$TITLE}"
                FINAL_AUTHOR="''${META_AUTHOR:-$AUTHOR}"
                
                TARGET_DIR="$REMOTE_BOOKS_DIR/$FINAL_AUTHOR/$FINAL_TITLE"
                
                echo "Book: $FINAL_TITLE"
                if [[ -n "$META_TITLE" && "$META_TITLE" != "$TITLE" ]]; then
                    echo "  (metadata title: $META_TITLE)"
                fi
                echo "Author: $FINAL_AUTHOR"
                if [[ -n "$META_AUTHOR" && "$META_AUTHOR" != "$AUTHOR" ]]; then
                    echo "  (metadata author: $META_AUTHOR)"
                fi
                echo "Format: .$FILE_EXT"
                echo "File: $(basename "$FILE_PATH")"
                
                # Create remote directory
                if ! ssh "$SERVER" "mkdir -p \"$TARGET_DIR\""; then
                    echo "❌ ERROR: Failed to create remote directory: $TARGET_DIR"
                    ((FAILED++))
                    echo ""
                    continue
                fi
                
                # Copy file with proper extension
                if rsync -aPvh "$FILE_PATH" "$SERVER:$TARGET_DIR/$FINAL_TITLE.$FILE_EXT"; then
                    echo "✓ Success"
                    ((SUCCESS++))
                else
                    echo "❌ Failed to copy"
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
            echo "============================================"
            ;;
            
        --comic)
            if (( $# < 3 )); then
                echo "Error: --comic requires Series, Volume, and at least one file"
                show_usage
            fi
            
            SERIES="$1"
            VOLUME="$2"
            shift 2
            
            if [[ $# -eq 0 ]]; then
                echo "Error: --comic requires at least one file"
                show_usage
            fi
            
            TARGET_DIR="$REMOTE_COMICS_DIR/$SERIES/$VOLUME"
            
            echo "============================================"
            echo "Adding Comics"
            echo "Series: $SERIES"
            echo "Volume: $VOLUME"
            echo "Files: $#"
            echo "============================================"
            echo ""
            
            # Check for utilities (needed for metadata reading)
            if ! command -v unzip &> /dev/null; then
                echo "⚠️  Warning: unzip not found. Install unzip for CBZ metadata reading."
            fi
            if ! command -v unrar &> /dev/null; then
                echo "⚠️  Warning: unrar not found. Install unrar for CBR metadata reading."
            fi
            if ! command -v unzip &> /dev/null && ! command -v unrar &> /dev/null; then
                echo "   Falling back to filename/sequential numbering only."
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
                if [[ ! -f "$FILE_PATH" && ! -d "$FILE_PATH" ]]; then
                    echo "❌ File/folder not found: $FILE_PATH"
                    continue
                fi
                
                FALLBACK_NUMBER=$(printf "%03d" $FALLBACK_NUM)
                NEW_NAME=$(determine_comic_filename "$FILE_PATH" "$FALLBACK_NUMBER")
                
                FILE_MAPPINGS+=("$FILE_PATH|$NEW_NAME")
                ((FALLBACK_NUM++))
            done
            
            # Sort by the new filenames to ensure proper chapter order
            IFS=$'\n' FILE_MAPPINGS=($(sort -t'|' -k2 <<<"''${FILE_MAPPINGS[*]}"))
            unset IFS
            
            SUCCESS=0
            FAILED=0
            
            for MAPPING in "''${FILE_MAPPINGS[@]}"; do
                FILE_PATH="''${MAPPING%%|*}"
                NEW_NAME="''${MAPPING##*|}"
                ORIGINAL_NAME=$(basename "$FILE_PATH")
                
                if is_directory "$FILE_PATH"; then
                    # Handle image folder
                    if [[ "$ORIGINAL_NAME" != "$NEW_NAME" ]]; then
                        echo "Copying folder: $ORIGINAL_NAME"
                        echo "             → $NEW_NAME"
                    else
                        echo "Copying folder: $NEW_NAME"
                    fi
                    
                    # Use rsync to copy entire directory
                    if rsync -aPvh "$FILE_PATH/" "$SERVER:$TARGET_DIR/$NEW_NAME/"; then
                        echo "✓ Success"
                        ((SUCCESS++))
                    else
                        echo "❌ Failed"
                        ((FAILED++))
                    fi
                else
                    # Handle regular file
                    if [[ "$ORIGINAL_NAME" != "$NEW_NAME" ]]; then
                        echo "Copying: $ORIGINAL_NAME"
                        echo "      → $NEW_NAME"
                    else
                        echo "Copying: $NEW_NAME"
                    fi
                    
                    if rsync -aPvh "$FILE_PATH" "$SERVER:$TARGET_DIR/$NEW_NAME"; then
                        echo "✓ Success"
                        ((SUCCESS++))
                    else
                        echo "❌ Failed"
                        ((FAILED++))
                    fi
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
            ;;
            
        *)
            echo "Error: Unknown mode '$MODE'"
            show_usage
            ;;
    esac
  '';

in
{
  home.packages = [
    addbooks
  ];
}
