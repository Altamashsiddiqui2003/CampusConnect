<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.User, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
    List<User> users = (List<User>) request.getAttribute("users");
    String searchQuery = (String) request.getAttribute("searchQuery");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Search - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        .avatar-img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            background: var(--bg-elevated);
        }
        .avatar-fallback {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: var(--bg-elevated);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--aqua);
            font-size: 1.5rem;
            border: 1px solid var(--border-glow);
        }
        @media (max-width: 576px) {
            .avatar-img, .avatar-fallback {
                width: 40px !important;
                height: 40px !important;
                font-size: 1.2rem;
            }
            .btn-sm {
                padding: 0.25rem 0.5rem;
                font-size: 0.75rem;
            }
            .card-body {
                padding: 1rem;
            }
            h6 {
                font-size: 0.9rem;
            }
            p {
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body class="bg-dark">
    <!-- Responsive Navbar with toggler -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark bg-dark border-bottom border-secondary">
        <div class="container">
            <a class="navbar-brand" href="home.jsp"><i class="fas fa-graduation-cap me-2"></i>CampusConnect</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <div class="navbar-nav ms-auto">
                    <a class="nav-link" href="home.jsp"><i class="fas fa-home fa-lg"></i></a>
                    <a class="nav-link active" href="search.jsp"><i class="fas fa-search fa-lg"></i></a>
                    <a class="nav-link" href="messages.jsp"><i class="fas fa-paper-plane fa-lg"></i></a>
                    <a class="nav-link" href="profile.jsp"><i class="fas fa-user fa-lg"></i></a>
                    <a class="nav-link" href="auth?action=logout"><i class="fas fa-sign-out-alt fa-lg"></i></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container my-3 my-md-4">
        <!-- Search form - full width on mobile -->
        <div class="row justify-content-center mb-4">
            <div class="col-12 col-md-8 col-lg-7">
                <form action="searchs" method="get" class="d-flex gap-2">
                    <input type="text" name="q" class="form-control bg-dark text-white border-secondary" 
                           placeholder="Search for students by username or name..." 
                           value="<%= searchQuery != null ? searchQuery : "" %>" required>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Search</button>
                </form>
            </div>
        </div>

        <!-- Search results or placeholder -->
        <% if (searchQuery != null) { %>
            <div class="row justify-content-center">
                <div class="col-12 col-md-8 col-lg-7">
                    <h5 class="mb-3 fw-bold text-aqua d-flex align-items-center gap-2 flex-wrap">
                        <i class="fas fa-search"></i> Results for "<%= searchQuery %>"
                        <% if (users != null) { %><span class="badge bg-secondary"><%= users.size() %></span><% } %>
                    </h5>
                    <% if (users != null && !users.isEmpty()) { 
                        for (User user : users) { 
                            String userPic = user.getProfilePicture();
                            boolean hasPic = userPic != null && !userPic.trim().isEmpty();
                            boolean isSelf = (user.getUserId() == currentUser.getUserId());
                    %>
                        <div class="card bg-dark border-secondary mb-3">
                            <div class="card-body p-3">
                                <div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <!-- Avatar with fallback -->
                                        <% if (hasPic) { %>
                                            <img src="<%= userPic %>" class="avatar-img" 
                                                 onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                            <div class="avatar-fallback" style="display: none;"><i class="fas fa-user-circle"></i></div>
                                        <% } else { %>
                                            <div class="avatar-fallback"><i class="fas fa-user-circle"></i></div>
                                        <% } %>
                                        <div>
                                            <h6 class="mb-0 fw-bold text-white"><%= user.getFullName() != null ? user.getFullName() : "User" %></h6>
                                            <p class="text-secondary mb-0 small">@<%= user.getUserName() %></p>
                                            <% if (user.getBio() != null && !user.getBio().isEmpty()) { %>
                                                <p class="text-secondary mb-0 small mt-1"><%= user.getBio().length() > 60 ? user.getBio().substring(0, 60) + "..." : user.getBio() %></p>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="d-flex gap-2 w-100 w-sm-auto justify-content-start">
                                        <% if (isSelf) { %>
                                            <a href="profile.jsp" class="btn btn-outline-primary btn-sm flex-grow-1 flex-sm-grow-0">My Profile</a>
                                        <% } else { %>
                                            <a href="other_profile?username=<%= user.getUserName() %>" class="btn btn-outline-primary btn-sm flex-grow-1 flex-sm-grow-0">View</a>
                                            <a href="chat.jsp?userId=<%= user.getUserId() %>" class="btn btn-primary btn-sm flex-grow-1 flex-sm-grow-0">Message</a>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } 
                    } else { %>
                        <div class="text-center py-5">
                            <i class="fas fa-user-slash fa-3x text-secondary mb-3"></i>
                            <h5 class="text-secondary">No users found</h5>
                            <p class="text-secondary">Try searching with different keywords</p>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } else { %>
            <!-- Empty state with search prompt -->
            <div class="row justify-content-center">
                <div class="col-12 col-md-8 col-lg-7">
                    <div class="card bg-dark border-secondary text-center py-5">
                        <i class="fas fa-search fa-3x text-secondary mb-3"></i>
                        <h5 class="text-secondary">Search for Students</h5>
                        <p class="text-secondary">Find and connect with other students on campus</p>
                        <p class="text-secondary small">Search by username or full name</p>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>