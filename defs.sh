echo
grep def $1 | sed 's/^.*def//' | sort
echo "----------------------------------"
grep def $1 | sed 's/^.*def//' | wc -l
echo
