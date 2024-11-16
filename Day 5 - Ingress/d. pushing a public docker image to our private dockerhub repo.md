
Docker has create a 3 tier web app, for which we have donwloaded the voting.yaml file. from this We will download all public docker image, and then push it to our private repo to see the functioning of how private images work with KB.

You can refer it here - https://github.com/dockersamples/example-voting-app


`docker pull kiran2361993/testing:latestappresults`

This will result in error as our management server does not have docker installed


# Install docker

`sudo apt update`
`sudo apt install docker.io -y`

`sudo usermod -aG docker ubuntu`

Log out from VM, then do docker login again to reflect updated groups. We have added ubuntu to docker group now
`docker login`


! Note - grant acess to the user they want to use to interact with docker and run docker commands.

To grant access to your user to run the docker command, you should add the user to the Docker Linux group. Docker group is create by default when docker is installed.

    sudo usermod -aG docker ubuntu


After this if we runn the command - docker pull kiran2361993/testing:latestappresults, it will work.

```
docker images
REPOSITORY             TAG                IMAGE ID       CREATED       SIZE
kiran2361993/testing   latestappresults   c5edb72ee85e   4 years ago   146MB

```

## Pushing this image to private repo

- We will open our Docker hub account and create a private repo. This is our private repo - adminnik/votingapp
- We will tag the above image we have downloaded as results. votingapp is name of our private repo.

`docker tag kiran2361993/testing:latestappresults adminnik/votingapp:results`

```
docker images
REPOSITORY             TAG                IMAGE ID       CREATED       SIZE
adminnik/votingapp     results            c5edb72ee85e   4 years ago   146MB
kiran2361993/testing   latestappresults   c5edb72ee85e   4 years ago   146MB

```

- After this we will push it to our private repo

`docker push adminnik/votingapp:results`


- If you are trying to push for first time, first do `docker login`, otherwise you will get error 

`denied: requested access to the resource is denied`

- Once success, we can see the image in our private repo. We will do the similar for vote image. We will pull the public image, tag it as vote, and push to our private docker hub

### Pull public image
`docker pull kiran2361993/testing:latestappvote`

```
docker images
REPOSITORY             TAG                IMAGE ID       CREATED       SIZE
adminnik/votingapp     results            c5edb72ee85e   4 years ago   146MB
kiran2361993/testing   latestappresults   c5edb72ee85e   4 years ago   146MB
kiran2361993/testing   latestappvote      917d9ec7f695   4 years ago   84.2MB

```
### Tag it 
`docker tag kiran2361993/testing:latestappvote adminnik/votingapp:vote`
```
docker images
REPOSITORY             TAG                IMAGE ID       CREATED       SIZE
adminnik/votingapp     results            c5edb72ee85e   4 years ago   146MB
kiran2361993/testing   latestappresults   c5edb72ee85e   4 years ago   146MB
adminnik/votingapp     vote               917d9ec7f695   4 years ago   84.2MB
kiran2361993/testing   latestappvote      917d9ec7f695   4 years ago   84.2MB
```

### Push to private docker hub registry
ubuntu@ip-172-31-85-128:~$ docker push adminnik/votingapp:vote
The push refers to repository [docker.io/adminnik/votingapp]
eac017dfb5f4: Mounted from kiran2361993/testing 

## The last image is worker image which is backend

`docker pull kiran2361993/testing:latestappworker`

```
docker images
REPOSITORY             TAG                IMAGE ID       CREATED       SIZE
kiran2361993/testing   latestappworker    3ac88adf88f7   4 years ago   1.72GB
adminnik/votingapp     results            c5edb72ee85e   4 years ago   146MB
kiran2361993/testing   latestappresults   c5edb72ee85e   4 years ago   146MB
adminnik/votingapp     vote               917d9ec7f695   4 years ago   84.2MB
kiran2361993/testing   latestappvote      917d9ec7f695   4 years ago   84.2MB
```

### tag it

`docker tag kiran2361993/testing:latestappworker adminnik/votingapp:worker`

```
docker tag kiran2361993/testing:latestappworker adminnik/votingapp:worker
ubuntu@ip-172-31-85-128:~$ docker images
REPOSITORY             TAG                IMAGE ID       CREATED       SIZE
adminnik/votingapp     worker             3ac88adf88f7   4 years ago   1.72GB
kiran2361993/testing   latestappworker    3ac88adf88f7   4 years ago   1.72GB
adminnik/votingapp     results            c5edb72ee85e   4 years ago   146MB
kiran2361993/testing   latestappresults   c5edb72ee85e   4 years ago   146MB
adminnik/votingapp     vote               917d9ec7f695   4 years ago   84.2MB
kiran2361993/testing   latestappvote      917d9ec7f695   4 years ago   84.2MB
```

### push to private repo

docker push adminnik/votingapp:worker 
The push refers to repository [docker.io/adminnik/votingapp]
280b08d4ae2e: Mounted from kiran2361993/testing 


# Deleting all downloaded images

Since we have now pushed all docker images to our docker hub, we will delete all the images

`docker rmi $(docker images -aq) -f`
```
docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```

We will prune to remove any dangling images as well

```
docker system prune
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

Are you sure you want to continue? [y/N] y
Total reclaimed space: 0B

```


In voting.yaml, we will now give reference to our private repo where all images are kept. we will make changes to line 140, 181, 218