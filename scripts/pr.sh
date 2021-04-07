rm -rf pr
for pr in `git ls-remote   |awk '{print $2}'  |grep -v merge |sort -n  -t / -k 3 |tail -n 10 `;do 
    git fetch origin $pr
    git checkout $pr
    dir=pr/`echo $pr|awk -F '/' '{print $3}'`
    make html;mkdir -p dir
    mv build/html/* dir/
done
git checkout master

