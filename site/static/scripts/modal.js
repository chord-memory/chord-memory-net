var overlay = document.getElementById("overlay");
var modal = document.getElementById("modal");
var covers = document.getElementsByClassName("media-cover");

function openModal() {
  overlay.style.display = "block";
}

function closeModal() {
  overlay.style.display = "none";
}

function modalClick(e) {
  e.preventDefault();
  e.stopPropagation();
  e.stopImmediatePropagation();
  return false;
}

overlay.addEventListener('click', closeModal);
modal.addEventListener('click', modalClick);

for (var cover of covers) {
  cover.addEventListener('click', openModal);
};
