echo
echo "Public defs"
echo "-----------"
grep '^ *def' $1 | grep -v defp | sed 's/^.*def//' | sed 's/do$//'| sort
echo "----------------------------------"
grep '^ *def' $1 | grep -v defp | wc -l
echo

echo
echo "Private defs"
echo "------------"
grep '^ *defp' $1 | sed 's/^.*defp//' | sed 's/do$//' | sort
echo "----------------------------------"
grep '^ *defp' $1 | wc -l
echo
wc $1
