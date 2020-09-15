#!/bin/bash
if [[ -z $1 ]]; then
  echo "usage: $0 <Kubernetes Object>"
  exit 1
fi
OBJ=$1
TMPF=`mktemp`
TMPF2="${TMPF}2"
OUT="./$OBJ.yaml"
kubectl explain --recursive $OBJ > $TMPF
KIND=`sed -rn 's/^KIND:\s+(.+)$/\1/ p' $TMPF`
VERS=`sed -rn 's/^VERSION:\s+(.+)$/\1/ p' $TMPF`
sed -rn '/^FIELDS/,$ p' $TMPF > $TMPF2
sed -r \
" /FIELDS:/ d;
  s|^\s{3}||;
  s|   |  |g;
  s|(^apiVersion)\s+.+|\1: $VERS|;
  s|(^kind)\s+.+|\1: $KIND|;
  s|\s+<Object>|: |;
  s|\s+<string>|: s|;
  s|\s+<integer>|: i|;
  s|\s+<boolean>|: b|;
  s|\s+(<.+>)|: \1|;" $TMPF2 > $TMPF
cat $TMPF |\
  sed -r "/^status:/,$ d" |\
  sed -r "s|(^([ ]+).+<\[\]Object>)|\1\n\2-|" |\
  sed -r "s|(.+)<\[\]Object>|\1|" |\
  sed -r "s|(^([ ]+).+<\[\]string>)|\1\n\2- s|" |\
  sed -r "s|(.+)<\[\]string>|\1|" |\
  sed -r "s|(^([ ]+).+<\[\]integer>)|\1\n\2- i|" |\
  sed -r "s|(.+)<\[\]integer>|\1|" > $TMPF2
mv $TMPF2 $OUT
echo $OUT
rm -f $TMPF $TMPF2
