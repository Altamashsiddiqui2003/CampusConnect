<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Home - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        /* additional responsive tweaks */
        @media (max-width: 576px) {
            .card-body {
                padding: 1.25rem;
            }
            h5 {
                font-size: 1.1rem;
            }
            .btn {
                font-size: 0.85rem;
                padding: 0.4rem 0.8rem;
            }
        }
    </style>
</head>
<body class="bg-dark">
    <!-- Responsive Navbar with toggler -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark bg-dark border-bottom border-secondary">
        <div class="container">
            <a class="navbar-brand" href="posts.jsp"><i class="fas fa-graduation-cap me-2"></i>CampusConnect</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <div class="navbar-nav ms-auto">
                    <a class="nav-link active" href="posts.jsp"><i class="fas fa-home fa-lg"></i></a>
                    <a class="nav-link" href="search.jsp"><i class="fas fa-search fa-lg"></i></a>
                    <a class="nav-link" href="messages.jsp"><i class="fas fa-paper-plane fa-lg"></i></a>
                    <a class="nav-link" href="profile.jsp"><i class="fas fa-user fa-lg"></i></a>
                    <a class="nav-link" href="auth?action=logout"><i class="fas fa-sign-out-alt fa-lg"></i></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container my-3 my-md-4">
        <div class="row justify-content-center">
            <div class="col-12 col-md-8 col-lg-7">
                <!-- Welcome Card -->
                <div class="card bg-dark border-secondary mb-4">
                    <div class="card-body">
                        <h5 class="text-aqua">Welcome to CampusConnect!</h5>
                        <p class="text-secondary">This is your home feed. Posts from you and users you follow will appear here.</p>
                        <a href="profile.jsp" class="btn btn-primary">View Your Profile</a>
                    </div>
                </div>

                <!-- Empty Feed Placeholder -->
                <div class="card bg-dark border-secondary">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-newspaper fa-3x text-secondary mb-3"></i>
                        <h5 class="text-secondary">No Posts Yet</h5>
                        <p class="text-secondary">Follow some users to see their posts here!</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>