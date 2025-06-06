let isOnDuty = false;
let playerData = null;

// Listen for NUI messages
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openPoliceMenu':
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
    
    document.getElementById('police-menu').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeMenu() {
    document.getElementById('police-menu').style.display = 'none';
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

function arrestPlayer() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/arrestPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function searchPlayer() {
    if (!isOnDuty) return;
    
    fetch(`https://${GetParentResourceName()}/searchPlayer`, {
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

// Fine Modal Functions
function showFineModal() {
    if (!isOnDuty) return;
    
    document.getElementById('fine-modal').style.display = 'flex';
    document.getElementById('fine-amount').focus();
}

function closeFineModal() {
    document.getElementById('fine-modal').style.display = 'none';
    // Reset form
    document.getElementById('fine-amount').value = '';
    document.getElementById('fine-reason').value = 'Geschwindigkeitsüberschreitung';
    document.getElementById('custom-reason').value = '';
    document.getElementById('custom-reason-group').style.display = 'none';
}

function submitFine() {
    const amount = document.getElementById('fine-amount').value;
    const reasonSelect = document.getElementById('fine-reason').value;
    const customReason = document.getElementById('custom-reason').value;
    
    if (!amount || amount <= 0) {
        alert('Bitte geben Sie einen gültigen Betrag ein!');
        return;
    }
    
    const reason = reasonSelect === 'Andere' ? customReason : reasonSelect;
    
    if (!reason.trim()) {
        alert('Bitte geben Sie einen Grund ein!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/finePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            amount: parseInt(amount),
            reason: reason
        })
    });
    
    closeFineModal();
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
function checkLicense() {
    if (!isOnDuty) return;
    console.log('Check License functionality - to be implemented');
}

function openRadio() {
    if (!isOnDuty) return;
    console.log('Radio functionality - to be implemented');
}

function openDispatch() {
    if (!isOnDuty) return;
    console.log('Dispatch functionality - to be implemented');
}

function checkWarrants() {
    if (!isOnDuty) return;
    console.log('Check Warrants functionality - to be implemented');
}

function checkFines() {
    if (!isOnDuty) return;
    console.log('Check Fines functionality - to be implemented');
}

function checkVehicles() {
    if (!isOnDuty) return;
    console.log('Check Vehicles functionality - to be implemented');
}

function checkPersons() {
    if (!isOnDuty) return;
    console.log('Check Persons functionality - to be implemented');
}

// Handle fine reason change
document.addEventListener('DOMContentLoaded', function() {
    const fineReason = document.getElementById('fine-reason');
    const customReasonGroup = document.getElementById('custom-reason-group');
    
    if (fineReason) {
        fineReason.addEventListener('change', function() {
            if (this.value === 'Andere') {
                customReasonGroup.style.display = 'block';
            } else {
                customReasonGroup.style.display = 'none';
            }
        });
    }
});

// ESC key to close menu
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        // Close any open modals first
        if (document.getElementById('fine-modal').style.display === 'flex') {
            closeFineModal();
        } else if (document.getElementById('announcement-modal').style.display === 'flex') {
            closeAnnouncementModal();
        } else if (document.getElementById('police-menu').style.display === 'block') {
            closeMenu();
        }
    }
});

// Prevent right-click context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});