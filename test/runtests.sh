#! /bin/sh

set -e

cd "$(dirname $0)"

if [ -n "$*" ]; then
  tests=$(ls -1r "$@")
else
  tests=$(ls -1r *-tests.sh)
fi

for t in $tests; do
    printf "# # #\n# # # Test: $t\n# # #\n"
    printf "# #\n# # Shell: bash\n# #\n"
    rm /bin/sh && ln -s bash /bin/sh
    sh $t
    printf "\n# #\n# # Shell: dash\n# #\n"
    rm /bin/sh && ln -s dash /bin/sh
    sh $t
    printf "# #\n# # Shell: lksh\n# #\n"
    rm /bin/sh && ln -s lksh /bin/sh
    sh $t
#    printf "# #\n# # Shell: posh\n# #\n"
#    rm /bin/sh && ln -s posh /bin/sh
#    posh $t
    rm /bin/sh && ln -s zsh /bin/sh
    printf "\n# #\n# # Shell: zsh\n# #\n"
    env SHUNIT_PARENT=$t zsh -y +o function_argzero $t
done

# Restore Debian default
rm /bin/sh && ln -s dash /bin/sh
