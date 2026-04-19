// Scroll to bottom of messages
       const messagesContainer = document.getElementById('messagesContainer');
       if(messagesContainer) {
           messagesContainer.scrollTop = messagesContainer.scrollHeight;
       }
       
       let countdown = 10;
       let countdownInterval;
       let isSendingMessage = false;
       
       // Update countdown timer
       function updateCountdown() {
           const countdownElement = document.getElementById('countdown');
           countdownElement.textContent = countdown;
           
           if (countdown <= 0) {
               countdown = 10; // Reset to 10 seconds
           } else {
               countdown--;
           }
       }
       
       // Auto-refresh function
       function autoRefresh() {
           // Don't refresh if we're in the middle of sending a message
           if (isSendingMessage) {
               console.log('Skipping refresh - message sending in progress');
               return;
           }
           
           const refreshIndicator = document.getElementById('refreshIndicator');
           
           // Show refresh indicator
           refreshIndicator.style.display = 'block';
           
           // Refresh the page after a short delay to show the indicator
           setTimeout(() => {
               location.reload();
           }, 500);
       }
       
       // Start countdown timer
       countdownInterval = setInterval(updateCountdown, 1000);
       
       // Start auto-refresh every 10 seconds (10000 milliseconds)
       setInterval(autoRefresh, 10000);
       
       // Handle message form submission
       document.getElementById('messageForm').addEventListener('submit', function(e) {
           e.preventDefault();
           
           const messageInput = document.getElementById('messageInput');
           const content = messageInput.value.trim();
           
           if (content === '') return;
           
           // Prevent multiple submissions
           if (isSendingMessage) {
               console.log('Message already being sent, please wait...');
               return;
           }
           
           // Set sending flag
           isSendingMessage = true;
           
           // Disable send button to prevent double clicks
           const sendButton = document.getElementById('sendButton');
           sendButton.disabled = true;
           sendButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
           
           const formData = new FormData(this);
           formData.append('action', 'send');
           
           fetch('message', {
               method: 'POST',
               body: new URLSearchParams(formData)
           })
           .then(response => {
               if (response.ok) {
                   document.getElementById('messageInput').value = '';
                   console.log('Message sent successfully');
                   
                   // Refresh immediately after sending message
                   setTimeout(() => {
                       location.reload();
                   }, 300);
               } else {
                   alert('Error sending message');
                   // Re-enable button on error
                   isSendingMessage = false;
                   sendButton.disabled = false;
                   sendButton.innerHTML = '<i class="fas fa-paper-plane"></i>';
               }
           })
           .catch(error => {
               alert('Error sending message: ' + error);
               // Re-enable button on error
               isSendingMessage = false;
               sendButton.disabled = false;
               sendButton.innerHTML = '<i class="fas fa-paper-plane"></i>';
           });
       });
       
       // Enter key to submit message
       document.getElementById('messageInput').addEventListener('keypress', function(e) {
           if (e.key === 'Enter') {
               document.getElementById('messageForm').dispatchEvent(new Event('submit'));
           }
       });
       
       // Search chats
       document.getElementById('chatSearch').addEventListener('input', function(e) {
           const searchTerm = e.target.value.toLowerCase();
           const chatItems = document.querySelectorAll('.chat-item');
           
           chatItems.forEach(item => {
               const userName = item.querySelector('.chat-user-name').textContent.toLowerCase();
               const lastMessage = item.querySelector('.chat-last-message').textContent.toLowerCase();
               
               if (userName.includes(searchTerm) || lastMessage.includes(searchTerm)) {
                   item.style.display = 'flex';
               } else {
                   item.style.display = 'none';
               }
           });
       });
       
       // Open chat with user
       function openChat(userId) {
           window.location.href = 'chat.jsp?userId=' + userId;
       }
       
       // Open new chat modal
       function openNewChatModal() {
           const modal = new bootstrap.Modal(document.getElementById('newChatModal'));
           modal.show();
           
           // Load users for new chat
           loadUsersForNewChat();
       }
       
       // Load users for new chat
       function loadUsersForNewChat(searchTerm = '') {
           fetch('message?action=users&query=' + encodeURIComponent(searchTerm))
               .then(response => response.json())
               .then(users => {
                   const userList = document.getElementById('userList');
                   userList.innerHTML = '';
                   
                   if (users.length === 0) {
                       userList.innerHTML = '<p class="text-muted text-center py-3">No users found</p>';
                       return;
                   }
                   
                   users.forEach(user => {
                       const userDiv = document.createElement('div');
                       userDiv.className = 'd-flex align-items-center p-2 border-bottom cursor-pointer hover-bg-light';
                       userDiv.innerHTML = `
                           <img src="${user.profilePicture || 'https://via.placeholder.com/40'}" 
                                class="rounded-circle me-3" width="40" height="40">
                           <div>
                               <div class="fw-bold">${user.fullName}</div>
                               <small class="text-muted">@${user.userName}</small>
                           </div>
                       `;
                       userDiv.onclick = () => window.location.href = 'chat.jsp?userId=' + user.userId;
                       userList.appendChild(userDiv);
                   });
               })
               .catch(error => {
                   console.error('Error loading users:', error);
                   document.getElementById('userList').innerHTML = '<p class="text-danger text-center py-3">Error loading users</p>';
               });
       }
       
       // Search users in new chat modal
       document.getElementById('userSearch').addEventListener('input', function(e) {
           loadUsersForNewChat(e.target.value);
       });
       
       // Refresh chat manually
       function refreshChat() {
           const refreshIndicator = document.getElementById('refreshIndicator');
           refreshIndicator.style.display = 'block';
           setTimeout(() => {
               location.reload();
           }, 300);
       }
       
    
       
       // Scroll to bottom
       function scrollToBottom() {
           if (messagesContainer) {
               messagesContainer.scrollTop = messagesContainer.scrollHeight;
           }
       }
       
       // Clean up when page is about to unload
       window.addEventListener('beforeunload', function() {
           clearInterval(countdownInterval);
       });
       
       console.log('Chat page loaded. Auto-refresh enabled.');