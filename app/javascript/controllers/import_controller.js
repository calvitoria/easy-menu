import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput", "fileName", "uploadBox", "uploadIcon", 
    "form", "submitButton", "results", "accordionButton",
    "accordionIcon", "accordionContent"
  ]

  connect() {
    if (process.env.NODE_ENV === 'development') {
      console.log("Import controller connected");
    }
  }

  handleFileChange() {
    if (this.fileInputTarget.files.length > 0) {
      const file = this.fileInputTarget.files[0];
      this.fileNameTarget.textContent = `Selected: ${file.name}`;
      this.fileNameTarget.classList.remove('hidden');
      
      this.uploadBoxTarget.classList.remove('border-gray-300');
      this.uploadBoxTarget.classList.add('border-indigo-400');
    } else {
      this.fileNameTarget.classList.add('hidden');
      this.uploadBoxTarget.classList.remove('border-indigo-400');
      this.uploadBoxTarget.classList.add('border-gray-300');
    }
  }

  highlightUpload() {
    this.uploadBoxTarget.classList.add('border-indigo-300');
    this.uploadIconTarget.classList.add('text-indigo-300');
  }

  unhighlightUpload() {
    if (!this.fileInputTarget.files.length) {
      this.uploadBoxTarget.classList.remove('border-indigo-300');
      this.uploadIconTarget.classList.remove('text-indigo-300');
    }
  }

  toggleAccordion() {
    const isExpanded = this.accordionButtonTarget.getAttribute('aria-expanded') === 'true';
    this.accordionButtonTarget.setAttribute('aria-expanded', !isExpanded);
    this.accordionContentTarget.classList.toggle('hidden');
    
    this.accordionIconTarget.classList.toggle('rotate-180');
  }

  downloadTemplate() {
    const template = {
      "restaurants": [
        {
          "name": "Restaurant Name",
          "description": "Restaurant description",
          "address": "123 Main Street, City",
          "email": "contact@restaurant.com",
          "active": true,
          "menus": [
            {
              "name": "Menu Name",
              "description": "Menu description",
              "active": true,
              "menu_items": [
                {
                  "name": "Menu Item Name",
                  "price": 10.00,
                  "description": "Menu item description",
                  "available": true
                }
              ]
            }
          ]
        }
      ]
    };

    const dataStr = JSON.stringify(template, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = 'restaurants_template.json';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  }

  async handleSubmit(event) {
    event.preventDefault();
    
    const formData = new FormData(this.formTarget);
    
    this.showLoadingState();
    
    try {
      const response = await fetch(this.formTarget.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      });
      
      const result = await response.json();
      
      if (result.success) {
        this.displaySuccessResults(result);
      } else {
        this.displayErrorResults(result);
      }
      
    } catch (error) {
      console.error('Import error:', error);
      this.displayNetworkError();
    } finally {
      this.resetSubmitButton();
    }
  }

  displaySuccessResults(result) {
    const template = document.getElementById('success-results-template');
    const clone = template.content.cloneNode(true);
    
    const errorCount = result.logs ? result.logs.filter(log => log.level === 'ERROR').length : 0;
    
    const statusBadge = clone.querySelector('.results-status');
    if (errorCount > 0) {
      statusBadge.classList.remove('bg-green-100', 'text-green-800');
      statusBadge.classList.add('bg-yellow-100', 'text-yellow-800');
      statusBadge.textContent = '⚠️ Completed with issues';
    }
    
    const durationElement = clone.querySelector('.duration-display');
    if (result.duration) {
      durationElement.textContent = `${result.duration.toFixed(2)}s`;
    }
    
    if (result.summary) {
      const summaryContainer = clone.querySelector('.summary-container');
      if (errorCount > 0) {
        summaryContainer.classList.remove('bg-green-50', 'border-green-200');
        summaryContainer.classList.add('bg-yellow-50', 'border-yellow-200');
      }
      
      summaryContainer.innerHTML = `
        <div class="flex">
          <div class="flex-shrink-0">
            ${errorCount > 0 ? this.getWarningIcon() : this.getSuccessIcon()}
          </div>
          <div class="ml-3">
            <p class="text-sm ${errorCount > 0 ? 'text-yellow-800' : 'text-green-800'}">${result.summary}</p>
          </div>
        </div>
      `;
    }
    
    if (result.stats) {
      this.updateStats(clone, result.stats);
    }
    
    if (result.logs && result.logs.length > 0) {
      this.updateLogs(clone, result.logs, errorCount);
    }
    
    if (result.audit_log_id) {
      const auditContainer = clone.querySelector('.audit-container');
      auditContainer.classList.remove('hidden');
      auditContainer.innerHTML = `
        <div class="text-xs text-gray-500">
          <p>Audit Log ID: <span class="font-mono bg-gray-100 px-2 py-1 rounded">${result.audit_log_id}</span></p>
          <p class="mt-1">Import completed: ${new Date(result.timestamp).toLocaleString()}</p>
        </div>
      `;
    }
    
    this.displayResults(clone);
  }

  displayErrorResults(result) {
    const template = document.getElementById('error-results-template');
    const clone = template.content.cloneNode(true);
    
    const errorContainer = clone.querySelector('.error-details');
    errorContainer.innerHTML = `
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h4 class="text-sm font-medium text-red-800">${result.error || 'Import Failed'}</h4>
          <div class="mt-2 text-sm text-red-700">
            <p>${result.message || 'There was an error importing the file.'}</p>
            ${result.details ? `<p class="mt-1">Details: ${result.details}</p>` : ''}
          </div>
        </div>
      </div>
    `;
    
    if (result.logs && result.logs.length > 0) {
      this.updateErrorLogs(clone, result.logs);
    }
    
    this.displayResults(clone);
  }

  displayNetworkError() {
    const template = document.getElementById('network-error-template');
    const clone = template.content.cloneNode(true);
    this.displayResults(clone);
  }

  displayResults(content) {
    this.resultsTarget.innerHTML = '';
    this.resultsTarget.appendChild(content);
    this.resultsTarget.classList.remove('hidden');
    
    this.resultsTarget.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  clearResults() {
    this.resultsTarget.innerHTML = '';
    this.resultsTarget.classList.add('hidden');
    this.formSectionTarget.classList.remove('hidden');
    
    const oldFileInput = this.fileInputTarget;
    const newFileInput = oldFileInput.cloneNode(true);
    
    oldFileInput.parentNode.replaceChild(newFileInput, oldFileInput);
    
    this.fileInputTarget = newFileInput;
    
    this.fileInputTarget.addEventListener('change', this.handleFileChange.bind(this));
    
    this.formTarget.reset();
    
    this.fileNameTarget.textContent = '';
    this.fileNameTarget.classList.add('hidden');
    this.uploadBoxTarget.classList.remove('border-indigo-400', 'border-indigo-300');
    this.uploadBoxTarget.classList.add('border-gray-300');
    this.uploadIconTarget.classList.remove('text-indigo-300');
    this.resetAccordion();
  }

  // Helper methods
  showLoadingState() {
    this.submitButtonTarget.disabled = true;
    this.submitButtonTarget.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Importing...
    `;
  }

  resetSubmitButton() {
    this.submitButtonTarget.disabled = false;
    this.submitButtonTarget.textContent = 'Import Restaurants';
  }

  getSuccessIcon() {
    return `
      <svg class="h-5 w-5 text-green-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>
    `;
  }

  getWarningIcon() {
    return `
      <svg class="h-5 w-5 text-yellow-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
      </svg>
    `;
  }

  updateStats(clone, stats) {
    const statsContainer = clone.querySelector('.stats-container');
    
    statsContainer.innerHTML = `
      ${this.createStatCard('Restaurants', stats.restaurants)}
      ${this.createStatCard('Menus', stats.menus)}
      ${this.createStatCard('Menu Items', stats.menu_items)}
    `;
  }

  createStatCard(title, data) {
    if (!data) return '';
    
    return `
      <div class="bg-gray-50 rounded-lg p-4">
        <h4 class="text-sm font-medium text-gray-900 mb-2">${title}</h4>
        <div class="grid grid-cols-3 gap-2">
          <div class="text-center">
            <p class="text-xs text-gray-500">Created</p>
            <p class="text-lg font-bold text-green-600">${data.created || 0}</p>
          </div>
          <div class="text-center">
            <p class="text-xs text-gray-500">Updated</p>
            <p class="text-lg font-bold text-blue-600">${data.updated || 0}</p>
          </div>
          <div class="text-center">
            <p class="text-xs text-gray-500">Errors</p>
            <p class="text-lg font-bold ${data.errors > 0 ? 'text-red-600' : 'text-gray-600'}">${data.errors || 0}</p>
          </div>
        </div>
      </div>
    `;
  }

  updateLogs(clone, logs, errorCount) {
    const logsContainer = clone.querySelector('.logs-container');
    const infoCount = logs.length - errorCount;
    
    let logsHtml = `
      <div class="flex justify-between items-center mb-3">
        <div>
          <h4 class="text-sm font-medium text-gray-900">Import Logs</h4>
          <p class="text-xs text-gray-500">${logs.length} log entries (${infoCount} info, ${errorCount} errors)</p>
        </div>
        <span class="text-xs text-gray-500">${logs.length} entries</span>
      </div>
      <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 rounded-lg">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-300">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Message</th>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Time</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
    `;
    
    logs.forEach(log => {
      const isError = log.level === 'ERROR';
      const statusColor = isError ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800';
      const statusIcon = isError ? '✗' : '✓';
      const statusText = isError ? 'Error' : 'Info';
      const rowBg = isError ? 'bg-red-50' : '';
      
      logsHtml += `
        <tr class="${rowBg}">
          <td class="px-3 py-3 whitespace-nowrap">
            <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${statusColor}">
              ${statusIcon} ${statusText}
            </span>
          </td>
          <td class="px-3 py-3 text-sm text-gray-900">${log.message || ''}</td>
          <td class="px-3 py-3 whitespace-nowrap text-xs text-gray-500">${this.formatTimestamp(log.timestamp)}</td>
        </tr>
      `;
    });
    
    logsHtml += `
            </tbody>
          </table>
        </div>
      </div>
    `;
    
    logsContainer.innerHTML = logsHtml;
  }

  updateErrorLogs(clone, logs) {
    const logsContainer = clone.querySelector('.error-logs-container');
    logsContainer.classList.remove('hidden');
    
    let logsHtml = `
      <h4 class="text-sm font-medium text-gray-900 mb-3">Error Logs</h4>
      <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 rounded-lg">
        <table class="min-w-full divide-y divide-gray-300">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Message</th>
              <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Time</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
    `;
    
    logs.forEach(log => {
      const message = log.message || (typeof log === 'object' ? JSON.stringify(log) : log);
      
      logsHtml += `
        <tr class="bg-red-50">
          <td class="px-3 py-3 whitespace-nowrap">
            <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium bg-red-100 text-red-800">
              ✗ Error
            </span>
          </td>
          <td class="px-3 py-3 text-sm text-gray-900">${message}</td>
          <td class="px-3 py-3 whitespace-nowrap text-xs text-gray-500">${this.formatTimestamp(log.timestamp)}</td>
        </tr>
      `;
    });
    
    logsHtml += `
          </tbody>
        </table>
      </div>
    `;
    
    logsContainer.innerHTML = logsHtml;
  }

  formatTimestamp(timestamp) {
    if (!timestamp) return '';
    try {
      const date = new Date(timestamp);
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    } catch (e) {
      return timestamp;
    }
  }
}