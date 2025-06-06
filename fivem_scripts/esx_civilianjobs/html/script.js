let playerData = null;
let currentJob = null;
let jobInProgress = false;
let jobStartTime = null;
let jobTimer = null;
let totalEarnings = 0;

// Listen for NUI messages
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openCivilianMenu':
            openMenu(data);
            break;
        case 'updateJobStatus':
            updateJobStatus(data);
            break;
        case 'jobCompleted':
            showJobCompletion(data);
            break;
    }
});

function openMenu(data) {
    playerData = data.playerData;
    currentJob = data.currentJob;
    jobInProgress = data.jobInProgress;
    
    updateJobInfo();
    updateJobCards();
    loadStatistics();
    
    document.getElementById('civilian-menu').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeMenu() {
    document.getElementById('civilian-menu').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function updateJobInfo() {
    const jobText = document.getElementById('current-job-text');
    const jobStatus = document.getElementById('job-status');
    
    const jobNames = {
        'unemployed': 'Arbeitslos',
        'garbage': 'Müllmann',
        'fisherman': 'Fischer',
        'delivery': 'Lieferfahrer',
        'construction': 'Bauarbeiter',
        'clothing': 'Kleidungsladen',
        'taxi': 'Taxi Fahrer'
    };
    
    jobText.textContent = `Aktueller Job: ${jobNames[currentJob] || 'Unbekannt'}`;
    
    if (jobInProgress) {
        jobStatus.textContent = 'Aktiv';
        jobStatus.className = 'status-active';
        showJobControl();
    } else {
        jobStatus.textContent = 'Inaktiv';
        jobStatus.className = 'status-inactive';
        hideJobControl();
    }
}

function updateJobCards() {
    const jobCards = document.querySelectorAll('.job-card');
    
    jobCards.forEach(card => {
        const jobType = card.getAttribute('data-job');
        const startBtn = card.querySelector('.btn-start');
        
        if (jobInProgress) {
            if (jobType === currentJob) {
                card.classList.add('job-active');
                startBtn.textContent = 'Läuft...';
                startBtn.disabled = true;
                startBtn.classList.add('btn-loading');
            } else {
                startBtn.textContent = 'Job beenden um zu wechseln';
                startBtn.disabled = true;
                startBtn.style.opacity = '0.5';
            }
        } else {
            card.classList.remove('job-active');
            startBtn.innerHTML = '<i class="fas fa-play"></i> Job starten';
            startBtn.disabled = false;
            startBtn.classList.remove('btn-loading');
            startBtn.style.opacity = '1';
        }
    });
}

function startJob(jobType) {
    if (jobInProgress) {
        alert('Du hast bereits einen Job aktiv! Beende ihn zuerst.');
        return;
    }
    
    // Add loading state
    const card = document.querySelector(`[data-job="${jobType}"]`);
    const btn = card.querySelector('.btn-start');
    btn.classList.add('btn-loading');
    btn.disabled = true;
    
    fetch(`https://${GetParentResourceName()}/startJob`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ jobType: jobType })
    }).then(() => {
        // Job started successfully
        jobInProgress = true;
        currentJob = jobType;
        jobStartTime = Date.now();
        totalEarnings = 0;
        
        updateJobInfo();
        updateJobCards();
        startJobTimer();
        
        // Show success animation
        card.classList.add('success-flash');
        setTimeout(() => card.classList.remove('success-flash'), 500);
        
    }).catch(() => {
        // Error starting job
        btn.classList.remove('btn-loading');
        btn.disabled = false;
        
        card.classList.add('error-flash');
        setTimeout(() => card.classList.remove('error-flash'), 500);
    });
}

function stopJob() {
    if (!jobInProgress) {
        return;
    }
    
    if (confirm('Bist du sicher, dass du den Job beenden möchtest?')) {
        fetch(`https://${GetParentResourceName()}/stopJob`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({})
        });
        
        // Reset local state
        jobInProgress = false;
        currentJob = 'unemployed';
        stopJobTimer();
        
        updateJobInfo();
        updateJobCards();
    }
}

function showJobControl() {
    const controlPanel = document.getElementById('job-control');
    controlPanel.style.display = 'block';
}

function hideJobControl() {
    const controlPanel = document.getElementById('job-control');
    controlPanel.style.display = 'none';
}

function startJobTimer() {
    if (jobTimer) {
        clearInterval(jobTimer);
    }
    
    jobTimer = setInterval(() => {
        if (jobStartTime) {
            const elapsed = Date.now() - jobStartTime;
            const hours = Math.floor(elapsed / 3600000);
            const minutes = Math.floor((elapsed % 3600000) / 60000);
            const seconds = Math.floor((elapsed % 60000) / 1000);
            
            const timeString = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            document.getElementById('job-time').textContent = timeString;
        }
    }, 1000);
}

function stopJobTimer() {
    if (jobTimer) {
        clearInterval(jobTimer);
        jobTimer = null;
    }
    
    document.getElementById('job-time').textContent = '00:00:00';
    document.getElementById('job-earnings').textContent = '$0';
    document.getElementById('job-progress').textContent = '0/0';
}

function updateJobStatus(data) {
    if (data.earnings) {
        totalEarnings += data.earnings;
        document.getElementById('job-earnings').textContent = `$${totalEarnings.toLocaleString()}`;
    }
    
    if (data.progress) {
        document.getElementById('job-progress').textContent = data.progress;
    }
}

function showJobCompletion(data) {
    // Show completion animation
    const card = document.querySelector(`[data-job="${currentJob}"]`);
    if (card) {
        card.classList.add('job-completed');
        setTimeout(() => card.classList.remove('job-completed'), 1000);
    }
    
    // Reset job state
    jobInProgress = false;
    currentJob = 'unemployed';
    stopJobTimer();
    
    updateJobInfo();
    updateJobCards();
    
    // Update statistics
    loadStatistics();
}

function loadStatistics() {
    // Mock statistics for now - in real implementation, these would come from server
    const stats = {
        totalJobs: 42,
        totalEarned: 125650,
        bestJob: 'Fischer',
        totalTime: 18
    };
    
    document.getElementById('total-jobs').textContent = stats.totalJobs;
    document.getElementById('total-earned').textContent = `$${stats.totalEarned.toLocaleString()}`;
    document.getElementById('best-job').textContent = stats.bestJob;
    document.getElementById('total-time').textContent = `${stats.totalTime}h`;
    
    // Animate counter updates
    animateCounter('total-jobs', 0, stats.totalJobs, 1000);
    animateCounter('total-earned', 0, stats.totalEarned, 1500, '$');
    animateCounter('total-time', 0, stats.totalTime, 800, '', 'h');
}

function animateCounter(elementId, start, end, duration, prefix = '', suffix = '') {
    const element = document.getElementById(elementId);
    const startTime = Date.now();
    
    function update() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        const current = Math.floor(start + (end - start) * easeOutCubic(progress));
        element.textContent = prefix + current.toLocaleString() + suffix;
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }
    
    requestAnimationFrame(update);
}

function easeOutCubic(t) {
    return 1 - Math.pow(1 - t, 3);
}

// Job-specific functions
function getJobDescription(jobType) {
    const descriptions = {
        'garbage': {
            title: 'Müllmann',
            icon: 'fas fa-trash-alt',
            description: 'Sammle Müll in der ganzen Stadt und verdiene Geld für jeden Container.',
            earnings: '$50-150 pro Container',
            time: '~30 Minuten Route',
            bonus: 'Müllwagen inklusive'
        },
        'fishing': {
            title: 'Fischer',
            icon: 'fas fa-fish',
            description: 'Angle an verschiedenen Stellen und verkaufe deine Fänge für gutes Geld.',
            earnings: '$25-500 pro Fisch',
            time: '5 Angelplätze',
            bonus: 'Seltene Fische = Mehr Geld'
        },
        'delivery': {
            title: 'Lieferfahrer',
            icon: 'fas fa-shipping-fast',
            description: 'Liefere Pakete zu verschiedenen Adressen in der Stadt.',
            earnings: '$100-250 pro Lieferung',
            time: '5 Lieferstellen',
            bonus: 'Lieferwagen inklusive'
        },
        'construction': {
            title: 'Bauarbeiter',
            icon: 'fas fa-hard-hat',
            description: 'Arbeite auf Baustellen und verdiene durch körperliche Arbeit.',
            earnings: '$150-350 pro Arbeit',
            time: '4 Baustellen',
            bonus: 'Stunden-Bonus'
        },
        'clothing': {
            title: 'Kleidungsladen',
            icon: 'fas fa-tshirt',
            description: 'Arbeite in einem Kleidungsladen und verdiene Provision.',
            earnings: '10% Provision',
            time: 'Verkaufs-Bonus',
            bonus: 'Kunden bedienen'
        },
        'taxi': {
            title: 'Taxi Fahrer',
            icon: 'fas fa-taxi',
            description: 'Fahre Kunden zu ihren Zielen und verdiene pro Fahrt.',
            earnings: '$2 pro Meter + Trinkgeld',
            time: 'Taxi inklusive',
            bonus: 'Bewertungs-System'
        }
    };
    
    return descriptions[jobType] || null;
}

// Keyboard shortcuts
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
    
    // Quick job start shortcuts
    if (event.ctrlKey) {
        switch(event.key) {
            case '1':
                event.preventDefault();
                startJob('garbage');
                break;
            case '2':
                event.preventDefault();
                startJob('fishing');
                break;
            case '3':
                event.preventDefault();
                startJob('delivery');
                break;
            case '4':
                event.preventDefault();
                startJob('construction');
                break;
        }
    }
});

// Prevent right-click context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Add tooltips to job cards
document.addEventListener('DOMContentLoaded', function() {
    const jobCards = document.querySelectorAll('.job-card');
    
    jobCards.forEach(card => {
        const jobType = card.getAttribute('data-job');
        const description = getJobDescription(jobType);
        
        if (description) {
            card.setAttribute('data-tooltip', description.description);
            card.classList.add('tooltip');
        }
    });
});

// Auto-refresh job status
setInterval(() => {
    if (document.getElementById('civilian-menu').style.display === 'block' && jobInProgress) {
        // In real implementation, this would fetch updated status from server
        // For now, we'll just update the timer
    }
}, 5000);

// Sound effects (if available)
function playSound(soundType) {
    // This could trigger sound effects in the game
    switch(soundType) {
        case 'job_start':
            // Play job start sound
            break;
        case 'job_complete':
            // Play job completion sound
            break;
        case 'earnings':
            // Play earnings sound
            break;
    }
}

// Mobile touch support
let touchStartY = 0;
let touchEndY = 0;

document.addEventListener('touchstart', function(event) {
    touchStartY = event.changedTouches[0].screenY;
});

document.addEventListener('touchend', function(event) {
    touchEndY = event.changedTouches[0].screenY;
    handleSwipe();
});

function handleSwipe() {
    const swipeThreshold = 50;
    const diff = touchStartY - touchEndY;
    
    if (Math.abs(diff) > swipeThreshold) {
        if (diff > 0) {
            // Swipe up - could scroll or show more options
        } else {
            // Swipe down - could minimize or close
        }
    }
}

// Initialize menu when loaded
window.addEventListener('load', function() {
    // Any initialization code here
    console.log('Civilian Jobs Menu loaded');
});