# code from StackOverflow.com
# http://stackoverflow.com/questions/8087997/automatic-resizing-for-non-retina-image-versions
# by nschum http://stackoverflow.com/users/168939/nschum
#
#!/bin/bash
# Downsamples all retina ...@2x.png images.

echo "Downsampling retina images..."

dir=$(pwd)
find "$dir" -name "*@2x.png" | while read image; do

    outfile=$(dirname "$image")/$(basename "$image" @2x.png).png

    if [ "$image" -nt "$outfile" ]; then
        basename "$outfile"

        width=$(sips -g "pixelWidth" "$image" | awk 'FNR>1 {print $2}')
        height=$(sips -g "pixelHeight" "$image" | awk 'FNR>1 {print $2}')
        sips -z $(($height / 2)) $(($width / 2)) "$image" --out "$outfile"

        test "$outfile" -nt "$image" || exit 1
    fi
done
