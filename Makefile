IMAGE   := ansible-linux-ctrl
SOCK    := /var/run/docker.sock
RUN     := docker run --rm -v $(PWD):/project -w /project $(IMAGE)
RUN_DND := docker run --rm -v $(PWD):/project -v $(SOCK):$(SOCK) -w /project $(IMAGE)

# role=baseline_common  scenario=ubuntu2404
role     ?= baseline_common
scenario ?= ubuntu2404

.PHONY: build lint syntax-check molecule-test molecule-converge molecule-verify shell

build:
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE) .

lint: build
	$(RUN) ansible-lint

syntax-check: build
	$(RUN) ansible-playbook --syntax-check playbooks/baseline.yml

molecule-test: build
	$(RUN_DND) bash -c "cd roles/$(role) && molecule test -s $(scenario)"

molecule-converge: build
	$(RUN_DND) bash -c "cd roles/$(role) && molecule converge -s $(scenario)"

molecule-verify: build
	$(RUN_DND) bash -c "cd roles/$(role) && molecule verify -s $(scenario)"

shell: build
	docker run --rm -it -v $(PWD):/project -v $(SOCK):$(SOCK) -w /project $(IMAGE) bash
