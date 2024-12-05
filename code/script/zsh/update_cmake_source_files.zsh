#!/bin/zsh

# To use this script, one have to have the CMakeLists.txt file
# 1. SRC_DIR variable should be set in set\(SRC_DIR .*\) pattern.
# 2. set\(SRC_FILES\n(?:.*$\n)*\) patten.

# This script will find all .c and .cpp files in the $SRC_DIR} directory and set them to the SRC_FILES variable.

# Note that the script would remove the existing SRC_FILES variable and set the new one.
# Thus, if you have any  other source files not in the $SRC_DIR directory,
# you should add them to different variable and add them to the target.


find . -name "CMakeLists.txt" | while read -r cmake_file; do
    dir=$(dirname "$cmake_file")

    src_dir=$(grep -Eo 'set\(SRC_DIR[[:space:]]+[^)]+\)' "$cmake_file" | awk '{print $2}' | tr -d ')')
    if [[ -z "$src_dir" ]]; then
        echo "SRC_DIR variable not found in $cmake_file, skipping $dir"
        continue
    fi

    c_files=(${dir}/${src_dir}/*.c(N))
    cpp_files=(${dir}/${src_dir}/*.cpp(N))
    total_number=$((${#c_files} + ${#cpp_files}))
    temp_file=$(mktemp)
    awk -v c_files="$(printf '%s ' ${c_files##*/})" \
        -v cpp_files="$(printf '%s ' ${cpp_files##*/})" \
        -v src_dir="\${SRC_DIR}" '
    BEGIN {
        split(c_files, c_file_list)
        split(cpp_files, cpp_file_list)
    }
    /set\(SRC_FILES/ {
        print "set(SRC_FILES"
        for (i in c_file_list) {
            print "    " src_dir "/" c_file_list[i]
        }
        for (i in cpp_file_list) {
            print "    " src_dir "/" cpp_file_list[i]
        }
        print ")"
        while (getline > 0) {
            if ($0 ~ /^\s*\)/) break
        }
        next
    }
    { print }
    ' "$cmake_file" > "$temp_file"
    mv "$temp_file" "$cmake_file"

    echo "$total_number source files are set to SRC_FILES in $cmake_file"
done
