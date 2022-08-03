docker build -f $2/Dockerfile -t $1 $2
docker push $1
