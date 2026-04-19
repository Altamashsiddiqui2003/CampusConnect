<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.User, com.campusconnect.dao.MessageDAO, com.campusconnect.dao.UserDAO, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    MessageDAO messageDAO = new MessageDAO();
    List<User> chatUsers = messageDAO.getChatUsers(user.getUserId());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Messages - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        .list-group-item {
            background-color: var(--bg-card, #1e1e1e);
            transition: all 0.2s ease;
            border: none;
            border-radius: 12px;
            margin-bottom: 8px;
        }
        .list-group-item:hover {
            background-color: rgba(0, 229, 255, 0.08);
            transform: translateX(4px);
        }
        .avatar-img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
        .avatar-fallback {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--bg-elevated, #2a2a2a);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--aqua, #00e5ff);
            border: 1px solid rgba(0, 229, 255, 0.3);
        }
        @media (max-width: 576px) {
            .card-body { padding: 1rem; }
            .avatar-img, .avatar-fallback { width: 36px !important; height: 36px !important; }
            h6 { font-size: 0.9rem; }
            small { font-size: 0.7rem; }
            .btn { font-size: 0.85rem; padding: 0.4rem 0.8rem; }
        }
    </style>
</head>
<body class="bg-dark">
    <!-- Navbar with responsive toggler -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark bg-dark border-bottom border-secondary">
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
                    <a class="nav-link" href="profile.jsp"><i class="fas fa-user fa-lg"></i></a>
                    <a class="nav-link" href="auth?action=logout"><i class="fas fa-sign-out-alt fa-lg"></i></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container my-3 my-md-4">
        <div class="row justify-content-center">
            <div class="col-12 col-md-10 col-lg-8">
                <div class="card bg-dark border-secondary">
                    <div class="card-header bg-transparent border-secondary fw-bold text-aqua">
                        <i class="fas fa-comments me-2"></i>Messages
                    </div>
                    <div class="card-body p-2 p-md-4">
                        <% if (chatUsers.isEmpty()) { %>
                            <div class="text-center py-5">
                                <i class="fas fa-comment-slash fa-3x text-secondary mb-3"></i>
                                <p class="text-secondary">No conversations yet. Start a new chat!</p>
                            </div>
                        <% } else { %>
                            <div class="list-group">
                                <% for (User chatUser : chatUsers) { 
                                    String profilePic = chatUser.getProfilePicture();
                                    boolean hasPic = profilePic != null && !profilePic.trim().isEmpty();
                                %>
                                    <a href="chat.jsp?userId=<%= chatUser.getUserId() %>" class="list-group-item list-group-item-action bg-dark text-white">
                                        <div class="d-flex align-items-center gap-3">
                                            <% if (hasPic) { %>
                                                <!-- Show actual profile picture with fallback on error -->
                                                <img src="<%= profilePic %>" class="avatar-img" 
                                                     onerror="this.onerror=null; this.src='data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 24 24\' fill=\'%2300e5ff\'%3E%3Cpath d=\'M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z\'/%3E%3C/svg%3E';">
                                            <% } else { %>
                                                <!-- No profile picture: show fallback icon -->
                                                <div class="avatar-fallback">
                                                    <i class="fas fa-user-circle fa-lg"></i>
                                                </div>
                                            <% } %>
                                            <div>
                                                <h6 class="mb-0 fw-bold"><%= chatUser.getFullName() %></h6>
                                                <small class="text-secondary">@<%= chatUser.getUserName() %></small>
                                            </div>
                                        </div>
                                    </a>
                                <% } %>
                            </div>
                        <% } %>
                        <div class="mt-4 text-center">
                            <a href="search.jsp" class="btn btn-primary"><i class="fas fa-user-plus me-2"></i>Start New Chat</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>