cat > db.yml << EOF
session:
  name: "db"
  windows:
EOF

DATABASES="alpha esjobs eventproxy lmclyde lmstats lmsummary marker3 marker4 marker5 markerloc meta payload pdfreport reportoutput scan ssdlmsg tmclyde tmstats tmqueue tmstats tmsummary useraction wsmclyde wsmsummary"

for d in `echo $DATABASES`; do
cat >> db.yml << EOF
    - name: "${d}"
      root: "~"
      layout: even-vertical
      panes:
        - cmd: "myt db-${d}-master"
        - cmd: "ssh root@db-${d}-master"
EOF
done
