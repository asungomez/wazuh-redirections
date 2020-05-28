var formSelector = document.getElementById('redirection-selector');
var currentForm = formSelector.value;
displayForm(currentForm);

function displayForm(id) {
  document.getElementById(id).classList.remove('hidden');
}

function hideForm(id) {
  document.getElementById(id).classList.add('hidden');
}

function switchToForm(form) {
  const previousForm = currentForm;
  currentForm = form;
  displayForm(currentForm);
  hideForm(previousForm);
}

formSelector.addEventListener('change', function(event) {
  switchToForm(formSelector.value);
});