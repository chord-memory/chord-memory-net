VENV = .venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip

$(VENV)/bin/activate: 
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip

.PHONY: venv
venv: $(VENV)/bin/activate

.PHONY: install
install: venv
	$(PIP) install -r requirements.txt

.PHONY: build
build: install
	$(PYTHON) lambda/build.py

.PHONY: run
run: build
	$(PYTHON) -m http.server 8000 -d build
