DOCKER_REPO_NAME:= gcr.io/npav-172917/
DOCKER_IMAGE_NAME := spark-job-server-2.2.0-hadoop-2.7
GO_REPOSITORY_PATH := github.com/accedian/$(DOCKER_IMAGE_NAME)
DOCKER_VER := $(if $(DOCKER_VER),$(DOCKER_VER),latest)
 
DOCKER_FILE := Dockerfile

all: docker

docker: .FORCE
	docker build -f $(DOCKER_FILE) -t $(DOCKER_REPO_NAME)$(DOCKER_IMAGE_NAME):$(DOCKER_VER) .

push: docker
	docker push $(DOCKER_REPO_NAME)$(DOCKER_IMAGE_NAME):$(DOCKER_VER)

circleci-push: circleci-docker
	docker push $(DOCKER_REPO_NAME)$(DOCKER_IMAGE_NAME):$(DOCKER_VER)

circleci-docker: .FORCE
	docker build -f $(DOCKER_FILE) -t $(DOCKER_REPO_NAME)$(DOCKER_IMAGE_NAME):$(DOCKER_VER) .
	
.FORCE: 
clean:  
	rm -rf bin

