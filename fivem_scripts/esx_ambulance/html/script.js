let isOnDuty = false;
let playerData = null;
let currentMedicalItem = null;

// Listen for NUI messages
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openAmbulanceMenu':
            openMenu(data);
            break;
        case 'updateDuty':
            updateDutyStatus(data.onDuty);
            break;
    }
});

function openMenu(data) {
    playerData = data.playerData;
    isOnDuty = data.onDuty;
    
    updateDutyStatus(isOnDuty);
    updateButtonStates();
    
    document.getElementById('ambulance-menu').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeMenu() {
    document.getElementById('ambulance-menu').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function updateDutyStatus(onDuty) {
    isOnDuty = onDuty;
    const dutyText = document.getElementById('duty-text');
    const dutyBtn = document.getElementById('duty-toggle');
    
    if (onDuty) {
        dutyText.textContent = 'Im Dienst';
        dutyBtn.classList.add('on');
        dutyBtn.classList.remove('off');
    } else {
        dutyText.textContent = 'Außer Dienst';
        dutyBtn.classList.add('off');
        dutyBtn.classList.remove('on');
    }
    
    updateButtonStates();
}

function updateButtonStates() {
    const requiresDutyButtons = document.querySelectorAll('[data-requires-duty="true"]');
    
    requiresDutyButtons.forEach(button => {
        if (isOnDuty) {
            button.classList.remove('disabled');
            button.disabled = false;
        } else {
            button.classList.add('disabled');
            button.disabled = true;
        }
    });
}

function toggleDuty() {
    fetch(`https://${GetParentResourceName()}/toggleDuty`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function spawnVehicle(model) {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ model: model })
    });
}

function healPlayer() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/healPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function revivePlayer() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/revivePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function checkHealth() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/checkHealth`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function putInAmbulance() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/putInAmbulance`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function sendToHospital() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/sendToHospital`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function requestBackup() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/requestBackup`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function respondToCall() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/respondToCall`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

// Medical Item Modal Functions
function showMedicalItemModal(item) {
    if (!isOnDuty) return;
    
    currentMedicalItem = item;
    const modal = document.getElementById('medical-item-modal');
    const title = document.getElementById('item-modal-title');
    const info = document.getElementById('item-info');
    
    // Set item information
    const itemData = getMedicalItemData(item);
    title.textContent = itemData.title;
    info.innerHTML = `
        <h4>${itemData.name}</h4>
        <p>${itemData.description}</p>
    `;
    
    modal.style.display = 'flex';
    document.getElementById('item-amount').focus();
}

function closeMedicalItemModal() {
    document.getElementById('medical-item-modal').style.display = 'none';
    document.getElementById('item-amount').value = '1';
    currentMedicalItem = null;
}

function submitMedicalItem() {
    const amount = document.getElementById('item-amount').value;
    
    if (!amount || amount <= 0) {
        alert('Bitte geben Sie eine gültige Anzahl ein!');
        return;
    }
    
    if (!currentMedicalItem) {
        alert('Fehler: Kein Item ausgewählt!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/giveMedicalItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            item: currentMedicalItem,
            amount: parseInt(amount)
        })
    });
    
    closeMedicalItemModal();
}

function getMedicalItemData(item) {
    const items = {
        'bandage': {
            name: 'Verband',
            title: 'Verband geben',
            description: 'Einfacher Verband zur Wundversorgung. Stellt kleine Mengen Gesundheit wieder her.'
        },
        'medikit': {
            name: 'Medikit',
            title: 'Medikit geben',
            description: 'Vollständiges medizinisches Set. Stellt größere Mengen Gesundheit wieder her.'
        },
        'painkillers': {
            name: 'Schmerzmittel',
            title: 'Schmerzmittel geben',
            description: 'Schmerzmittel zur Behandlung von Verletzungen. Reduziert Schmerzen temporär.'
        },
        'morphine': {
            name: 'Morphin',
            title: 'Morphin geben',
            description: 'Starkes Schmerzmittel für schwere Verletzungen. Nur für medizinisches Personal.'
        }
    };
    
    return items[item] || { name: 'Unbekannt', title: 'Unbekanntes Item', description: 'Keine Beschreibung verfügbar.' };
}

// Bill Modal Functions
function showBillModal() {
    if (!isOnDuty) return;
    
    document.getElementById('bill-modal').style.display = 'flex';
    document.getElementById('bill-amount').focus();
}

function closeBillModal() {
    document.getElementById('bill-modal').style.display = 'none';
    document.getElementById('bill-amount').value = '';
    document.getElementById('bill-reason').value = 'Erste Hilfe';
    document.getElementById('custom-bill').value = '';
    document.getElementById('custom-bill-group').style.display = 'none';
}

function submitBill() {
    const amount = document.getElementById('bill-amount').value;
    const reasonSelect = document.getElementById('bill-reason').value;
    const customReason = document.getElementById('custom-bill').value;
    
    if (!amount || amount <= 0) {
        alert('Bitte geben Sie einen gültigen Betrag ein!');
        return;
    }
    
    const reason = reasonSelect === 'Andere' ? customReason : reasonSelect;
    
    if (!reason.trim()) {
        alert('Bitte geben Sie eine Behandlung ein!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/billPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            amount: parseInt(amount),
            reason: reason
        })
    });
    
    closeBillModal();
}

// Announcement Modal Functions
function showAnnouncementModal() {
    if (!isOnDuty) return;
    
    document.getElementById('announcement-modal').style.display = 'flex';
    document.getElementById('announcement-text').focus();
}

function closeAnnouncementModal() {
    document.getElementById('announcement-modal').style.display = 'none';
    document.getElementById('announcement-text').value = '';
}

function submitAnnouncement() {
    const text = document.getElementById('announcement-text').value;
    
    if (!text.trim()) {
        alert('Bitte geben Sie eine Nachricht ein!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/announcement`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            text: text
        })
    });
    
    closeAnnouncementModal();
}

// Other Functions (placeholder implementations)
function checkPatientRecords() {
    if (!isOnDuty) return;
    console.log('Patient Records functionality - to be implemented');
}

function prescribeMedication() {
    if (!isOnDuty) return;
    console.log('Prescribe Medication functionality - to be implemented');
}

function openDispatch() {
    if (!isOnDuty) return;
    console.log('Dispatch functionality - to be implemented');
}

function viewStats() {
    if (!isOnDuty) return;
    console.log('View Stats functionality - to be implemented');
}

function viewPatients() {
    if (!isOnDuty) return;
    console.log('View Patients functionality - to be implemented');
}

function viewDeadPlayers() {
    if (!isOnDuty) return;
    console.log('View Dead Players functionality - to be implemented');
}

function shiftReport() {
    if (!isOnDuty) return;
    console.log('Shift Report functionality - to be implemented');
}

// Handle bill reason change
document.addEventListener('DOMContentLoaded', function() {
    const billReason = document.getElementById('bill-reason');
    const customBillGroup = document.getElementById('custom-bill-group');
    const billAmount = document.getElementById('bill-amount');
    
    if (billReason) {
        billReason.addEventListener('change', function() {
            if (this.value === 'Andere') {
                customBillGroup.style.display = 'block';
            } else {
                customBillGroup.style.display = 'none';
                
                // Auto-fill amount based on treatment
                const amounts = {
                    'Erste Hilfe': 250,
                    'Wiederbelebung': 500,
                    'Krankenhaus Transport': 300,
                    'Intensive Behandlung': 750,
                    'Operation': 1500
                };
                
                if (amounts[this.value]) {
                    billAmount.value = amounts[this.value];
                }
            }
        });
    }
});

// ESC key to close menu/modals
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        // Close any open modals first
        if (document.getElementById('medical-item-modal').style.display === 'flex') {
            closeMedicalItemModal();
        } else if (document.getElementById('bill-modal').style.display === 'flex') {
            closeBillModal();
        } else if (document.getElementById('announcement-modal').style.display === 'flex') {
            closeAnnouncementModal();
        } else if (document.getElementById('ambulance-menu').style.display === 'block') {
            closeMenu();
        }
    }
});

// Prevent right-click context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Add emergency pulsing effect for critical buttons
function addEmergencyEffect(buttonId) {
    const button = document.getElementById(buttonId);
    if (button) {
        button.classList.add('emergency');
    }
}

function removeEmergencyEffect(buttonId) {
    const button = document.getElementById(buttonId);
    if (button) {
        button.classList.remove('emergency');
    }
}