
function toggleView() {
  const chart = document.getElementById('queryCountChart');
  const chartContainer = chart.parentElement;
  const table = document.getElementById('queryTable');
  const button = document.getElementById('toggleButton');
  if (chartContainer.style.display === 'none') {
    chartContainer.style.display = 'block';
    table.style.display = 'none';
    button.textContent = 'Show Table View';
  } else {
    chartContainer.style.display = 'none';
    table.style.display = 'table';
    button.textContent = 'Show chartContainer View';
  };
};

function toggleColumnContent() {
  const columnHeader = document.getElementById('columnHeader');
  const toggleContents = document.querySelectorAll('.toggle-content');
  const showSQL = columnHeader.textContent === 'File Path';

  columnHeader.textContent = showSQL ? 'SQL' : 'File Path';

  toggleContents.forEach(content => {
    const filepath = content.querySelector('.filepath');
    const sql = content.querySelector('.sql');

    if (showSQL) {
      filepath.style.display = 'none';
      sql.style.display = 'block';
    } else {
      filepath.style.display = 'block';
      sql.style.display = 'none';
    }
  });
}

function initializeChart(chartData) {
  console.log(chartData);
  const ctx = document.getElementById('queryCountChart').getContext('2d');
  const queryCountChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: chartData.labels,
      datasets: [
        {
          label: 'Dataset 1',
          data: chartData.data,
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          borderColor: 'rgba(75, 192, 192, 1)',
          borderWidth: 1
        }
      ]
    },
    options: {
      scales: {
        y: {
          type: 'logarithmic',
          beginAtZero: true,
          ticks: {
            callback: function(value, index, values) {
              if (value === 10 || value === 100 || value === 1000 || value === 10000) {
                return value.toString();
              }
              return null;
            }
          }
        }
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: function(tooltipItem) {
              const index = tooltipItem.dataIndex;
              const table = chartData.labels[index];
              // const locations = chartData.locations[table];
              // Aquí se podría hacer el stackgraph
              return [
                `Total Queries: ${tooltipItem.raw}`,
              ];
            }
          }
        }
      }
    }
  });
  document.getElementById('queryCountChart').parentElement.style.display = 'none';
}

function initializeChartCompare(chartData) {
  const ctx = document.getElementById('queryCountChart').getContext('2d');
  const queryCountChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: chartData.labels,
      datasets: [
        {
          label: chartData.data_1.name,
          data: chartData.data_1.data,
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          borderColor: 'rgba(75, 192, 192, 1)',
          borderWidth: 1
        },
        {
          label: chartData.data_2.name,
          data: chartData.data_2.data,
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)',
          borderWidth: 1
        }
      ]
    },
    options: {
      scales: {
        y: {
          type: 'logarithmic',
          beginAtZero: true,
          title: {
            display: true,
            text: 'Logarithmic Scale'
          },
          ticks: {
            callback: function(value, index, values) {
              if (value === 0 || value === 10 || value === 100 || value === 1000 || value === 10000) {
                return value.toString();
              }
              return null;
            }
          }
        }
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: function(tooltipItem) {
              const index = tooltipItem.dataIndex;
              const table = chartData.labels[index];
              // const locations = chartData1.locations[table];
              // Aquí se podría hacer el stackgraph
              return [
                `Total Queries: ${tooltipItem.raw}`,
              ];
            }
          }
        }
      }
    }
  });
  document.getElementById('queryCountChart').parentElement.style.display = 'none';
}