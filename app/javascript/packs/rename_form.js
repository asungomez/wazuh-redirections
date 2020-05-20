import autocomplete from "autocompleter";

var destinationPathInput = document.getElementById('destination_page');
var destinationIdInput = document.getElementById('destination_id');
var originPathInput = document.getElementById('origin_page');
var originIdInput = document.getElementById('origin_id');

const destinationsData = JSON.parse(document.getElementById('destinations-section').dataset.destinations);
const destinationsAutocomplete = filterForAutocomplete(destinationsData);
const originsData = JSON.parse(document.getElementById('origins-section').dataset.origins);
const originsAutocomplete = filterForAutocomplete(originsData);

destinationPathInput.addEventListener('change', function(event) {
  const destinationPath = destinationPathInput.value;
  if (destinationPath in destinationsData) {
    destinationIdInput.value = destinationsData[destinationPath];
  }
});

originPathInput.addEventListener('change', function(event) {
  const originPath = originPathInput.value;
  if (originPath in originsData) {
    originIdInput.value = originsData[originPath];
  }
});

autocomplete({
  input: destinationPathInput,
  emptyMsg: "No pages found",
  minLength: 1,
  fetch: function(text, update) {
      var suggestions = destinationsAutocomplete.filter(n => n.label.startsWith(text));
      update(suggestions);
  },
  onSelect: function(item) {
    destinationPathInput.value = item.label;
  }
});

autocomplete({
  input: originPathInput,
  emptyMsg: "No pages found",
  minLength: 1,
  fetch: function(text, update) {
      var suggestions = originsAutocomplete.filter(n => n.label.startsWith(text));
      update(suggestions);
  },
  onSelect: function(item) {
    originPathInput.value = item.label;
  }
});

function filterForAutocomplete(data) {
  return Object.keys(data).map(
    (path) => {
      const autocompleteItem = {
        label: path,
        value: path
      }
      return autocompleteItem;
    }
  );
}
