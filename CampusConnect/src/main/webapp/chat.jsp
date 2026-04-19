<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.User, com.campusconnect.model.Message, java.util.List, com.campusconnect.dao.UserDAO, com.campusconnect.dao.MessageDAO, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userIdParam = request.getParameter("userId");
    User otherUser = null;
    List<Message> messages = null;
    MessageDAO messageDAO = new MessageDAO();
    List<User> recentChatUsers = new ArrayList<>();
    
    if (userIdParam != null && !userIdParam.trim().isEmpty()) {
        int userId = Integer.parseInt(userIdParam);
        otherUser = new UserDAO().getUserById(userId);
        messages = messageDAO.getConversation(user.getUserId(), userId);
    }
    if (otherUser == null) {
        response.sendRedirect("messages.jsp");
        return;
    }
    recentChatUsers = messageDAO.getChatUsers(user.getUserId());
    recentChatUsers.removeIf(u -> u.getUserId() == user.getUserId());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat with <%= otherUser.getFullName() %> - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        /* Instagram-like chat styles - enhanced for mobile */
        .chat-container {
            max-width: 1400px;
            margin: 0 auto;
            background: var(--bg-dark);
            border-radius: 24px;
            overflow: hidden;
            height: calc(100vh - 80px);
            display: flex;
        }
        .chat-sidebar {
            width: 320px;
            background: var(--bg-card);
            border-right: var(--border-glow);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            animation: slideInLeft 0.4s ease-out;
        }
        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-20px); }
            to { opacity: 1; transform: translateX(0); }
        }
        .chat-user-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            cursor: pointer;
            transition: all 0.2s;
            border-bottom: 1px solid rgba(0, 229, 255, 0.1);
        }
        .chat-user-item:hover {
            background: rgba(0, 229, 255, 0.08);
            transform: translateX(4px);
        }
        .chat-user-item.active {
            background: rgba(0, 229, 255, 0.12);
            border-left: 3px solid var(--aqua);
        }
        .chat-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: var(--bg-dark);
        }
        .chat-header {
            padding: 0.75rem 1rem;
            border-bottom: var(--border-glow);
            background: var(--bg-card);
        }
        /* Instagram-like messages area */
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 1rem;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        /* Message bubbles */
        .message {
            display: flex;
            flex-direction: column;
            max-width: 80%;
            animation: fadeInUp 0.2s ease;
        }
        .message.own {
            align-self: flex-end;
        }
        .message.other {
            align-self: flex-start;
        }
        .message-bubble {
            padding: 8px 14px;
            border-radius: 20px;
            font-size: 0.9rem;
            line-height: 1.4;
            word-wrap: break-word;
            box-shadow: 0 1px 1px rgba(0,0,0,0.1);
        }
        /* Own message: aqua gradient (Instagram-like) */
        .message.own .message-bubble {
            background: linear-gradient(135deg, var(--aqua), var(--aqua-dark));
            color: #000;
            border-top-right-radius: 4px;
        }
        /* Other message: dark gray */
        .message.other .message-bubble {
            background: #2a2a2a;
            color: #e0e0e0;
            border-top-left-radius: 4px;
        }
        .message-time {
            font-size: 0.7rem;
            margin-top: 4px;
            opacity: 0.6;
            padding: 0 6px;
        }
        /* Typing indicator (Instagram style) */
        .typing-indicator {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            background: #2a2a2a;
            padding: 8px 14px;
            border-radius: 20px;
            width: fit-content;
            margin-bottom: 0.5rem;
            animation: fadeInUp 0.2s ease;
        }
        .typing-dots {
            display: flex;
            gap: 4px;
            align-items: center;
        }
        .typing-dots span {
            width: 8px;
            height: 8px;
            background: #b0b0b0;
            border-radius: 50%;
            display: inline-block;
            animation: typingBounce 1.4s infinite ease-in-out both;
        }
        .typing-dots span:nth-child(1) { animation-delay: -0.32s; }
        .typing-dots span:nth-child(2) { animation-delay: -0.16s; }
        @keyframes typingBounce {
            0%,80%,100% { transform: scale(0.6); opacity: 0.5; }
            40% { transform: scale(1); opacity: 1; }
        }
        .typing-text {
            font-size: 0.8rem;
            color: #b0b0b0;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }
        /* Input area */
        .chat-input-area {
            padding: 0.75rem 1rem;
            border-top: var(--border-glow);
            background: var(--bg-card);
        }
        .chat-input-area form {
            display: flex;
            gap: 0.75rem;
        }
        .chat-input-area input {
            flex: 1;
            background: #1e1e1e;
            border: none;
            color: var(--text-primary);
            border-radius: 30px;
            padding: 12px 20px;
            font-size: 0.9rem;
        }
        .chat-input-area input:focus {
            outline: none;
            background: #252525;
            box-shadow: 0 0 0 2px var(--aqua);
        }
        .chat-input-area button {
            background: var(--aqua);
            border: none;
            border-radius: 30px;
            padding: 0 20px;
            font-weight: bold;
        }
        .avatar-img { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
        .avatar-fallback { width: 40px; height: 40px; border-radius: 50%; background: #1e1e1e; display: flex; align-items: center; justify-content: center; color: var(--aqua); }
        .avatar-fallback.small { width: 32px; height: 32px; font-size: 1rem; }
        
        /* Mobile responsive styles */
        @media (max-width: 767.98px) {
            .chat-container {
                height: calc(100vh - 60px);
                border-radius: 0;
                margin: 0 -12px;
                width: calc(100% + 24px);
            }
            .chat-sidebar {
                display: none !important;
            }
            .chat-main {
                width: 100%;
            }
            .message {
                max-width: 85%;
            }
            .chat-header {
                padding: 0.5rem 0.75rem;
            }
            .chat-header h5 {
                font-size: 1rem;
            }
            .chat-header small {
                font-size: 0.7rem;
            }
            .chat-messages {
                padding: 0.75rem;
            }
            .message-bubble {
                font-size: 0.85rem;
                padding: 8px 12px;
            }
            .chat-input-area {
                padding: 0.5rem 0.75rem;
            }
            .chat-input-area input {
                padding: 10px 16px;
                font-size: 0.85rem;
            }
            .chat-input-area button {
                padding: 0 16px;
                font-size: 0.85rem;
            }
            .avatar-img, .avatar-fallback {
                width: 36px;
                height: 36px;
            }
            .navbar-brand {
                font-size: 1.1rem;
            }
            .nav-link {
                padding: 0.5rem 0.6rem;
            }
            .container {
                padding-left: 12px;
                padding-right: 12px;
            }
        }
        
        /* Tablet adjustments */
        @media (min-width: 768px) and (max-width: 991.98px) {
            .chat-sidebar {
                width: 280px;
            }
            .message {
                max-width: 75%;
            }
        }
        
        /* Offcanvas dark theme */
        .offcanvas {
            background-color: var(--bg-card);
            color: var(--text-primary);
        }
        .offcanvas-header {
            border-bottom: var(--border-glow);
        }
        .offcanvas-title {
            color: var(--aqua);
        }
        .btn-close-white {
            filter: invert(1) grayscale(100%) brightness(200%);
        }
        
        /* Navbar responsive improvements */
        .navbar-nav {
            flex-direction: row;
            gap: 0.5rem;
        }
        @media (max-width: 576px) {
            .navbar-nav {
                gap: 0.25rem;
            }
            .nav-link {
                padding: 0.4rem 0.5rem;
                font-size: 0.9rem;
            }
            .navbar-brand {
                font-size: 1rem;
            }
            .navbar-brand i {
                font-size: 0.9rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar - responsive with Bootstrap toggler -->
    <nav class="navbar navbar-expand-lg sticky-top">
        <div class="container">
            <a class="navbar-brand" href="home.jsp"><i class="fas fa-graduation-cap me-2"></i>CampusConnect</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <div class="navbar-nav ms-auto">
                    <a class="nav-link" href="home.jsp"><i class="fas fa-home fa-lg"></i></a>
                    <a class="nav-link" href="search.jsp"><i class="fas fa-search fa-lg"></i></a>
                    <a class="nav-link active" href="messages.jsp"><i class="fas fa-paper-plane fa-lg"></i></a>
                    <a class="nav-link" href="profile.jsp">
                        <% 
                            String profilePic = user.getProfilePicture();
                            boolean hasPic = profilePic != null && !profilePic.trim().isEmpty();
                        %>
                        <% if (hasPic) { %>
                            <img src="<%= profilePic %>" class="rounded-circle" width="32" height="32" 
                                 onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                            <div class="avatar-fallback small" style="display: none;"><i class="fas fa-user-circle"></i></div>
                        <% } else { %>
                            <div class="avatar-fallback small"><i class="fas fa-user-circle"></i></div>
                        <% } %>
                    </a>
                    <a class="nav-link" href="auth?action=logout"><i class="fas fa-sign-out-alt fa-lg"></i></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container mt-2 mt-md-3">
        <div class="chat-container">
            <!-- Desktop Sidebar (hidden on mobile) -->
            <div class="chat-sidebar">
                <div class="p-3 border-bottom"><h6 class="mb-0 fw-bold text-aqua"><i class="fas fa-comments me-2"></i>Recent Chats</h6></div>
                <div class="flex-grow-1 overflow-auto">
                    <% if (recentChatUsers.isEmpty()) { %>
                        <div class="text-center py-5"><i class="fas fa-comment-slash fa-2x text-secondary mb-2"></i><p class="text-secondary small">No chats yet</p></div>
                    <% } else {
                        for (User cu : recentChatUsers) {
                            boolean active = cu.getUserId() == otherUser.getUserId();
                            String chatUserPic = cu.getProfilePicture();
                            boolean chatUserHasPic = chatUserPic != null && !chatUserPic.trim().isEmpty();
                    %>
                        <div class="chat-user-item <%= active ? "active" : "" %>" onclick="location.href='chat.jsp?userId=<%= cu.getUserId() %>'">
                            <% if (chatUserHasPic) { %>
                                <img src="<%= chatUserPic %>" class="avatar-img" onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                <div class="avatar-fallback" style="display: none;"><i class="fas fa-user-circle"></i></div>
                            <% } else { %>
                                <div class="avatar-fallback"><i class="fas fa-user-circle"></i></div>
                            <% } %>
                            <div class="flex-grow-1"><div class="username"><%= cu.getFullName() %></div><div class="last-message">@<%= cu.getUserName() %></div></div>
                        </div>
                    <% } } %>
                </div>
            </div>

            <!-- Main chat area -->
            <div class="chat-main">
                <div class="chat-header d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center gap-2">
                        <!-- Mobile menu button to open offcanvas -->
                        <button class="btn btn-link text-white p-0 d-md-none me-2" type="button" data-bs-toggle="offcanvas" data-bs-target="#chatOffcanvas" aria-controls="chatOffcanvas">
                            <i class="fas fa-bars fa-lg"></i>
                        </button>
                        <a href="other_profile?username=<%= otherUser.getUserName() %>" class="text-decoration-none text-white">
                            <div class="d-flex align-items-center gap-2 gap-md-3">
                                <% String otherPic = otherUser.getProfilePicture(); boolean otherHasPic = otherPic != null && !otherPic.trim().isEmpty(); %>
                                <% if (otherHasPic) { %>
                                    <img src="<%= otherPic %>" class="avatar-img" onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div class="avatar-fallback" style="display: none;"><i class="fas fa-user-circle"></i></div>
                                <% } else { %>
                                    <div class="avatar-fallback"><i class="fas fa-user-circle"></i></div>
                                <% } %>
                                <div>
                                    <h5 class="mb-0 fw-bold"><%= otherUser.getFullName() %></h5>
                                    <small class="text-secondary">@<%= otherUser.getUserName() %></small>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div>
                        <button class="btn btn-sm btn-outline-secondary me-1 me-md-2" onclick="refreshChat()" title="Refresh">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="clearChat()" title="Clear chat">
                            <i class="fas fa-trash"></i> <span class="d-none d-sm-inline">Clear</span>
                        </button>
                    </div>
                </div>

                <!-- Messages container with Instagram style -->
                <div class="chat-messages" id="messagesContainer">
                    <div class="text-center text-secondary mt-5">
                        <i class="fas fa-spinner fa-spin fa-2x"></i>
                        <p>Loading messages...</p>
                    </div>
                </div>

                <div class="chat-input-area">
                    <form id="messageForm">
                        <input type="text" name="content" class="form-control" placeholder="Type a message..." id="messageInput" autocomplete="off" required>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> <span class="d-none d-sm-inline">Send</span></button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Mobile Offcanvas for chat list (visible only on mobile) -->
    <div class="offcanvas offcanvas-start d-md-none" tabindex="-1" id="chatOffcanvas" aria-labelledby="chatOffcanvasLabel">
        <div class="offcanvas-header">
            <h5 class="offcanvas-title" id="chatOffcanvasLabel"><i class="fas fa-comments me-2"></i>Recent Chats</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body p-0">
            <% if (recentChatUsers.isEmpty()) { %>
                <div class="text-center py-5"><i class="fas fa-comment-slash fa-2x text-secondary mb-2"></i><p class="text-secondary small">No chats yet</p></div>
            <% } else {
                for (User cu : recentChatUsers) {
                    boolean active = cu.getUserId() == otherUser.getUserId();
                    String chatUserPic = cu.getProfilePicture();
                    boolean chatUserHasPic = chatUserPic != null && !chatUserPic.trim().isEmpty();
            %>
                <div class="chat-user-item <%= active ? "active" : "" %>" onclick="navigateAndClose(<%= cu.getUserId() %>)">
                    <% if (chatUserHasPic) { %>
                        <img src="<%= chatUserPic %>" class="avatar-img" onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <div class="avatar-fallback" style="display: none;"><i class="fas fa-user-circle"></i></div>
                    <% } else { %>
                        <div class="avatar-fallback"><i class="fas fa-user-circle"></i></div>
                    <% } %>
                    <div class="flex-grow-1">
                        <div class="username"><%= cu.getFullName() %></div>
                        <div class="last-message">@<%= cu.getUserName() %></div>
                    </div>
                </div>
            <% } } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const otherUserId = <%= otherUser.getUserId() %>;
        const currentUserId = <%= user.getUserId() %>;
        let lastMessageId = 0;
        let pollingInterval = null;
        let isLoading = false;
        let typingTimer = null;
        const typingDelay = 1000;
        let isTypingCurrently = false;
        let typingIndicatorElement = null;

        const messagesContainer = document.getElementById('messagesContainer');
        const messageInput = document.getElementById('messageInput');
        
        // Offcanvas navigation helper
        function navigateAndClose(userId) {
            // Get offcanvas instance and hide it
            const offcanvasEl = document.getElementById('chatOffcanvas');
            const offcanvasInstance = bootstrap.Offcanvas.getInstance(offcanvasEl);
            if (offcanvasInstance) {
                offcanvasInstance.hide();
            }
            // Navigate after a small delay to allow offcanvas to close smoothly
            setTimeout(() => {
                window.location.href = 'chat.jsp?userId=' + userId;
            }, 150);
        }

        function escapeHtml(str) { if (!str) return ''; return str.replace(/[&<>]/g, function(m) { if (m==='&') return '&amp;'; if (m==='<') return '&lt;'; if (m==='>') return '&gt;'; return m; }); }
        function formatTime(timestamp) { if (!timestamp) return ''; try { return new Date(timestamp).toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'}); } catch(e){ return ''; } }
        function scrollToBottom() { messagesContainer.scrollTop = messagesContainer.scrollHeight; }

        // Instagram-like typing indicator
        function showTypingIndicator(show) {
            if (show && !isTypingCurrently) {
                if (typingIndicatorElement) typingIndicatorElement.remove();
                const div = document.createElement('div');
                div.className = 'typing-indicator';
                div.id = 'typingIndicatorMessage';
                div.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div><span class="typing-text">typing...</span>';
                messagesContainer.appendChild(div);
                typingIndicatorElement = div;
                isTypingCurrently = true;
                scrollToBottom();
            } else if (!show && isTypingCurrently) {
                if (typingIndicatorElement) typingIndicatorElement.remove();
                typingIndicatorElement = null;
                isTypingCurrently = false;
            }
        }

        function appendMessage(msg) {
            const wasTyping = isTypingCurrently;
            if (wasTyping) showTypingIndicator(false);
            const isOwn = msg.senderId === currentUserId;
            const msgTime = msg.timestamp ? formatTime(msg.timestamp) : '';
            const html = '<div class="message ' + (isOwn ? 'own' : 'other') + '" data-msg-id="' + msg.id + '">' +
                '<div class="message-bubble">' + escapeHtml(msg.content) + '</div>' +
                '<div class="message-time">' + msgTime + '</div></div>';
            messagesContainer.insertAdjacentHTML('beforeend', html);
            if (wasTyping) showTypingIndicator(true);
            scrollToBottom();
        }

        function renderAllMessages(messages) {
            if (!messages || messages.length === 0) {
                messagesContainer.innerHTML = '<div class="text-center text-secondary mt-5"><i class="fas fa-comment-dots fa-3x mb-3"></i><p>No messages yet. Start the conversation!</p></div>';
                lastMessageId = 0;
                return;
            }
            let html = '', maxId = 0;
            for (let msg of messages) {
                const isOwn = msg.senderId === currentUserId;
                const msgTime = msg.timestamp ? formatTime(msg.timestamp) : '';
                html += '<div class="message ' + (isOwn ? 'own' : 'other') + '" data-msg-id="' + msg.id + '">' +
                    '<div class="message-bubble">' + escapeHtml(msg.content) + '</div>' +
                    '<div class="message-time">' + msgTime + '</div></div>';
                if (msg.id > maxId) maxId = msg.id;
            }
            messagesContainer.innerHTML = html;
            lastMessageId = maxId;
            scrollToBottom();
        }

        function sendTyping(typing) {
            const params = new URLSearchParams();
            params.append('action', 'typing');
            params.append('receiverId', otherUserId);
            params.append('typing', typing ? 'true' : 'false');
            fetch('message', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params }).catch(console.error);
        }

        function onLocalTyping() {
            sendTyping(true);
            clearTimeout(typingTimer);
            typingTimer = setTimeout(function() { sendTyping(false); }, typingDelay);
        }

        messageInput.addEventListener('input', onLocalTyping);
        messageInput.addEventListener('blur', function() { sendTyping(false); clearTimeout(typingTimer); });

        function fetchNewMessages() {
            if (isLoading) return;
            isLoading = true;
            fetch('message?action=poll&userId=' + otherUserId + '&lastMessageId=' + lastMessageId, { method: 'GET', headers: { 'Accept': 'application/json' } })
            .then(res => res.json())
            .then(data => {
                const newMessages = data.messages || [];
                if (newMessages.length > 0) {
                    for (let msg of newMessages) {
                        appendMessage(msg);
                        if (msg.id > lastMessageId) lastMessageId = msg.id;
                    }
                }
                showTypingIndicator(data.otherTyping === true);
            })
            .catch(err => console.error('Polling error:', err))
            .finally(() => { isLoading = false; });
        }

        function loadAllMessages() {
            isLoading = true;
            fetch('message?action=poll&userId=' + otherUserId + '&lastMessageId=0', { method: 'GET', headers: { 'Accept': 'application/json' } })
            .then(res => res.json())
            .then(data => { renderAllMessages(data.messages || []); showTypingIndicator(false); })
            .catch(err => { console.error(err); messagesContainer.innerHTML = '<div class="text-center text-danger mt-5">Error loading messages. Please refresh.</div>'; })
            .finally(() => { isLoading = false; });
        }

        function sendMessage(content) {
            const params = new URLSearchParams();
            params.append('action', 'send');
            params.append('receiverId', otherUserId);
            params.append('content', content);
            return fetch('message', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params });
        }

        document.getElementById('messageForm').addEventListener('submit', function(e) {
            e.preventDefault();
            let content = messageInput.value.trim();
            if (!content) return;
            const sendBtn = this.querySelector('button');
            sendBtn.disabled = true;
            sendBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
            sendMessage(content).then(res => {
                if (res.ok) {
                    messageInput.value = '';
                    sendTyping(false);
                    clearTimeout(typingTimer);
                    fetchNewMessages();
                } else alert('Failed to send');
            }).catch(err => alert('Error: ' + err.message))
            .finally(() => { sendBtn.disabled = false; sendBtn.innerHTML = '<i class="fas fa-paper-plane"></i> <span class="d-none d-sm-inline">Send</span>'; });
        });

        function refreshChat() { loadAllMessages(); }
        function clearChat() {
            if (confirm('Clear all messages?')) {
                fetch('message?action=clear&receiverId=' + otherUserId, { method: 'POST' }).then(() => loadAllMessages());
            }
        }

        function startPolling() {
            if (pollingInterval) clearInterval(pollingInterval);
            pollingInterval = setInterval(() => { if (!document.hidden) fetchNewMessages(); }, 3000);
        }
        document.addEventListener('visibilitychange', function() { if (document.hidden) { if (pollingInterval) clearInterval(pollingInterval); } else startPolling(); });
        loadAllMessages();
        startPolling();
        window.addEventListener('beforeunload', () => { if (pollingInterval) clearInterval(pollingInterval); });
    </script>
</body>
</html>