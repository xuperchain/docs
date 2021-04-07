base_dir=pr
rm -rf ${base_dir}

for pr in `git ls-remote |awk '{print $2}'  |grep -v merge |sort -n  -t / -k 3 |tail -n 10 `;do 
    subdir=`echo $pr|awk -F '/' '{print $3}'`
    git fetch origin $pr:pr-${subdir}
    git checkout -- .
    git checkout pr-${subdir}
    git pull 
    make html;mkdir -p ${base_dir}/${subdir}
    mv build/html/* ${base_dir}/${subdir}
done
# Update Master Code
git checkout master
git pull 
