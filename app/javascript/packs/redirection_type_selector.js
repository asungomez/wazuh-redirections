var formSelector = document.getElementById('redirection-selector');
var currentForm = formSelector.value;
displayForm(currentForm);

function displayForm(id) {
  document.getElementById(id).classList.remove('hidden');
}

function hideForm(id) {
  document.getElementById(id).classList.add('hidden');
}

formSelector.addEventListener('change', function(event) {
  const previousForm = currentForm;
  currentForm = formSelector.value;
  displayForm(currentForm);
  hideForm(previousForm);
});