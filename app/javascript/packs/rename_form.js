
var destinationPathInput = document.getElementById('destination_page');
var destinationIdInput = document.getElementById('destination_id');
var originPathInput = document.getElementById('origin_page');
var originIdInput = document.getElementById('origin_id');

const destinationsData = JSON.parse(document.getElementById('destinations-section').dataset.destinations);
const originsData = JSON.parse(document.getElementById('origins-section').dataset.origins);

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

