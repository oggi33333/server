let gangData = null;
let playerGang = null;
let gangRank = 0;
let currentModal = null;

// Listen for NUI messages
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openGangMenu':
            openMenu(data);
            break;
    }
});

function openMenu(data) {
    gangData = data.gangData;
    playerGang = data.playerGang;
    gangRank = data.gangRank;
    
    updateGangInfo();
    updateButtonStates();
    
    document.getElementById('gang-menu').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeMenu() {
    document.getElementById('gang-menu').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function updateGangInfo() {
    if (gangData && gangData.gang) {
        document.getElementById('gang-name').textContent = playerGang.toUpperCase();
        
        // Update stats
        document.getElementById('gang-rank').textContent = `Rang: ${getRankName(gangRank)}`;
        document.getElementById('member-count').textContent = `Mitglieder: ${gangData.members ? gangData.members.length : 0}`;
        document.getElementById('gang-money').textContent = `Bank: $${formatNumber(gangData.gang.bank_money || 0)}`;
        document.getElementById('territory-count').textContent = `Territorien: ${gangData.territories ? gangData.territories.length : 0}`;
    }
}

function getRankName(rank) {
    const ranks = {
        1: 'Neuling',
        2: 'Mitglied',
        3: 'Veteran',
        4: 'Leutnant',
        5: 'Boss'
    };
    return ranks[rank] || 'Unbekannt';
}

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function updateButtonStates() {
    const requiresRankButtons = document.querySelectorAll('[data-requires-rank]');
    
    requiresRankButtons.forEach(button => {
        const requiredRank = parseInt(button.getAttribute('data-requires-rank'));
        
        if (gangRank >= requiredRank) {
            button.classList.remove('disabled');
            button.disabled = false;
        } else {
            button.classList.add('disabled');
            button.disabled = true;
        }
    });
}

// Member Management
function invitePlayer() {
    if (gangRank < 3) return;
    
    fetch(`https://${GetParentResourceName()}/invitePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function showMembersModal() {
    const modal = document.getElementById('members-modal');
    const membersList = document.getElementById('members-list');
    
    // Clear existing members
    membersList.innerHTML = '';
    
    if (gangData && gangData.members) {
        gangData.members.forEach(member => {
            const memberDiv = document.createElement('div');
            memberDiv.className = 'member-item';
            memberDiv.innerHTML = `
                <div class="member-info">
                    <h4>${member.player_name}</h4>
                    <p>Rang: ${getRankName(member.rank)} | Beigetreten: ${formatDate(member.joined_date)}</p>
                </div>
                <div class="member-actions">
                    ${gangRank >= 5 ? `
                        <button onclick="promotePlayer('${member.player_id}')">
                            <i class="fas fa-arrow-up"></i> Befördern
                        </button>
                        <button onclick="demotePlayer('${member.player_id}')">
                            <i class="fas fa-arrow-down"></i> Degradieren
                        </button>
                    ` : ''}
                    ${gangRank >= 4 && member.rank < gangRank ? `
                        <button onclick="kickPlayer('${member.player_id}')" style="background: #ef4444;">
                            <i class="fas fa-times"></i> Kicken
                        </button>
                    ` : ''}
                </div>
            `;
            membersList.appendChild(memberDiv);
        });
    }
    
    modal.style.display = 'flex';
    currentModal = 'members';
}

function closeMembersModal() {
    document.getElementById('members-modal').style.display = 'none';
    currentModal = null;
}

function promotePlayer(playerId) {
    fetch(`https://${GetParentResourceName()}/promotePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ playerId: playerId })
    });
    closeMembersModal();
}

function demotePlayer(playerId) {
    fetch(`https://${GetParentResourceName()}/demotePlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ playerId: playerId })
    });
    closeMembersModal();
}

function kickPlayer(playerId) {
    fetch(`https://${GetParentResourceName()}/kickPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ playerId: playerId })
    });
    closeMembersModal();
}

function leaveGang() {
    if (confirm('Bist du sicher, dass du die Gang verlassen möchtest?')) {
        fetch(`https://${GetParentResourceName()}/leaveGang`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({})
        });
        closeMenu();
    }
}

// Territory Management
function showTerritoriesModal() {
    const modal = document.getElementById('territories-modal');
    const territoriesList = document.getElementById('territories-list');
    
    // Clear existing territories
    territoriesList.innerHTML = '';
    
    if (gangData && gangData.territories) {
        gangData.territories.forEach(territory => {
            const territoryDiv = document.createElement('div');
            territoryDiv.className = `territory-item ${territory.owner_gang === playerGang ? 'owned' : 'enemy'}`;
            territoryDiv.innerHTML = `
                <h4>${territory.name}</h4>
                <p>Besitzer: ${territory.owner_gang || 'Neutral'}</p>
                <p>Einkommen: $${territory.income || 0}/h</p>
                <div class="territory-status">
                    <span>Status: ${territory.status || 'Friedlich'}</span>
                    ${territory.owner_gang !== playerGang && gangRank >= 2 ? `
                        <button onclick="attackTerritory(${territory.id})">Angreifen</button>
                    ` : ''}
                </div>
            `;
            territoriesList.appendChild(territoryDiv);
        });
    }
    
    modal.style.display = 'flex';
    currentModal = 'territories';
}

function closeTerritoriesModal() {
    document.getElementById('territories-modal').style.display = 'none';
    currentModal = null;
}

function showAttackModal() {
    if (gangRank < 2) return;
    
    const modal = document.getElementById('attack-modal');
    const select = document.getElementById('target-territory');
    
    // Clear existing options
    select.innerHTML = '<option value="">Territorium auswählen...</option>';
    
    // Add available territories (not owned by player's gang)
    if (gangData && gangData.territories) {
        gangData.territories.forEach(territory => {
            if (territory.owner_gang !== playerGang) {
                const option = document.createElement('option');
                option.value = territory.id;
                option.textContent = `${territory.name} (${territory.owner_gang || 'Neutral'})`;
                select.appendChild(option);
            }
        });
    }
    
    modal.style.display = 'flex';
    currentModal = 'attack';
}

function closeAttackModal() {
    document.getElementById('attack-modal').style.display = 'none';
    currentModal = null;
}

function confirmAttack() {
    const territoryId = document.getElementById('target-territory').value;
    
    if (!territoryId) {
        alert('Bitte wähle ein Territorium aus!');
        return;
    }
    
    if (confirm('Territorium-Angriff starten? Dies kostet $10,000 und dauert 5 Minuten.')) {
        fetch(`https://${GetParentResourceName()}/attackTerritory`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ territoryId: territoryId })
        });
        closeAttackModal();
    }
}

function attackTerritory(territoryId) {
    if (gangRank < 2) return;
    
    fetch(`https://${GetParentResourceName()}/attackTerritory`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ territoryId: territoryId })
    });
}

function defendTerritories() {
    fetch(`https://${GetParentResourceName()}/defendTerritory`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

// Gang Wars
function showGangWarsModal() {
    if (gangRank < 5) return;
    
    const modal = document.getElementById('gang-wars-modal');
    modal.style.display = 'flex';
    currentModal = 'gang-wars';
}

function closeGangWarsModal() {
    document.getElementById('gang-wars-modal').style.display = 'none';
    currentModal = null;
}

function startGangWar() {
    const targetGang = document.getElementById('target-gang').value;
    
    if (!targetGang) {
        alert('Bitte wähle eine Ziel-Gang aus!');
        return;
    }
    
    if (confirm(`Gang War gegen ${targetGang} starten? Dies kann nicht rückgängig gemacht werden!`)) {
        fetch(`https://${GetParentResourceName()}/startGangWar`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ targetGang: targetGang })
        });
        closeGangWarsModal();
    }
}

// Drug Operations
function startDrugRun() {
    fetch(`https://${GetParentResourceName()}/startDrugRun`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function sellDrugs() {
    fetch(`https://${GetParentResourceName()}/sellDrugs`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function showDrugStatsModal() {
    console.log('Drug Stats Modal - to be implemented');
}

function buyDrugSupplies() {
    if (gangRank < 3) return;
    console.log('Buy Drug Supplies - to be implemented');
}

// Weapon Operations
function showWeaponShop() {
    if (gangRank < 3) return;
    
    const modal = document.getElementById('weapon-shop-modal');
    modal.style.display = 'flex';
    currentModal = 'weapon-shop';
}

function closeWeaponShopModal() {
    document.getElementById('weapon-shop-modal').style.display = 'none';
    currentModal = null;
}

function buyWeapon(weaponType, price) {
    if (confirm(`${weaponType.toUpperCase()} für $${price} kaufen?`)) {
        fetch(`https://${GetParentResourceName()}/buyWeapons`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ 
                weaponType: weaponType,
                amount: 1
            })
        });
        closeWeaponShopModal();
    }
}

function showWeaponStorage() {
    console.log('Weapon Storage - to be implemented');
}

function upgradeWeapons() {
    if (gangRank < 4) return;
    console.log('Upgrade Weapons - to be implemented');
}

function sellWeapons() {
    if (gangRank < 3) return;
    console.log('Sell Weapons - to be implemented');
}

// Vehicle Functions
function spawnGangVehicle(model) {
    if (gangRank < 2) return;
    
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ model: model })
    });
}

function showGarageModal() {
    if (gangRank < 4) return;
    console.log('Gang Garage - to be implemented');
}

// Bank Functions
function showDepositModal() {
    const modal = document.getElementById('money-modal');
    const title = document.getElementById('money-modal-title');
    const confirmBtn = document.getElementById('money-confirm-btn');
    
    title.textContent = 'Geld einzahlen';
    confirmBtn.textContent = 'Einzahlen';
    confirmBtn.onclick = confirmDeposit;
    
    modal.style.display = 'flex';
    document.getElementById('money-amount').focus();
    currentModal = 'money';
}

function showWithdrawModal() {
    if (gangRank < 3) return;
    
    const modal = document.getElementById('money-modal');
    const title = document.getElementById('money-modal-title');
    const confirmBtn = document.getElementById('money-confirm-btn');
    
    title.textContent = 'Geld abheben';
    confirmBtn.textContent = 'Abheben';
    confirmBtn.onclick = confirmWithdraw;
    
    modal.style.display = 'flex';
    document.getElementById('money-amount').focus();
    currentModal = 'money';
}

function closeMoneyModal() {
    document.getElementById('money-modal').style.display = 'none';
    document.getElementById('money-amount').value = '';
    currentModal = null;
}

function confirmDeposit() {
    const amount = parseInt(document.getElementById('money-amount').value);
    
    if (!amount || amount <= 0) {
        alert('Bitte geben Sie einen gültigen Betrag ein!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/depositMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ amount: amount })
    });
    
    closeMoneyModal();
}

function confirmWithdraw() {
    const amount = parseInt(document.getElementById('money-amount').value);
    
    if (!amount || amount <= 0) {
        alert('Bitte geben Sie einen gültigen Betrag ein!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/withdrawMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ amount: amount })
    });
    
    closeMoneyModal();
}

function showTransactionHistory() {
    console.log('Transaction History - to be implemented');
}

function manageSalaries() {
    if (gangRank < 5) return;
    console.log('Manage Salaries - to be implemented');
}

// Utility Functions
function formatDate(timestamp) {
    const date = new Date(timestamp * 1000);
    return date.toLocaleDateString('de-DE');
}

// Event Listeners
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        // Close any open modals first
        if (currentModal) {
            switch(currentModal) {
                case 'members':
                    closeMembersModal();
                    break;
                case 'territories':
                    closeTerritoriesModal();
                    break;
                case 'attack':
                    closeAttackModal();
                    break;
                case 'gang-wars':
                    closeGangWarsModal();
                    break;
                case 'weapon-shop':
                    closeWeaponShopModal();
                    break;
                case 'money':
                    closeMoneyModal();
                    break;
            }
        } else if (document.getElementById('gang-menu').style.display === 'block') {
            closeMenu();
        }
    }
});

// Prevent right-click context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Auto-update gang info periodically
setInterval(function() {
    if (document.getElementById('gang-menu').style.display === 'block') {
        // Request updated gang info
        fetch(`https://${GetParentResourceName()}/updateGangInfo`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({})
        }).catch(() => {
            // Silent fail, don't spam console
        });
    }
}, 30000); // Update every 30 seconds