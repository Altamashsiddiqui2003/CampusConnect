<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        /* Fixed CSS – removed 3D transforms that caused click issues */
        .auth-card {
            transition: all 0.4s cubic-bezier(0.2, 0.9, 0.4, 1.1);
            /* Removed transform-style: preserve-3d – it was causing hit area bugs */
            animation: cardFloat 1s ease-out;
        }
        .auth-card:hover {
            transform: translateY(-8px); /* removed rotateX(3deg) – safe 2D only */
            box-shadow: 0 25px 40px -15px rgba(0, 229, 255, 0.4);
        }
        @keyframes cardFloat {
            from { opacity: 0; transform: translateY(30px); } /* removed rotateX */
            to { opacity: 1; transform: translateY(0); }
        }
        .form-control:focus {
            transform: scale(1.02); /* removed translateZ – safe 2D */
            box-shadow: 0 0 0 0.2rem rgba(0, 229, 255, 0.25);
        }
        .btn:hover {
            transform: translateY(-2px); /* removed translateZ – this was the main culprit */
            box-shadow: 0 10px 20px -5px rgba(0, 229, 255, 0.5);
        }
        /* responsive adjustments – unchanged */
        @media (max-width: 768px) {
            .auth-card {
                margin: 1rem;
            }
            .auth-card .p-4 {
                padding: 1.5rem !important;
            }
            h2.fw-bold {
                font-size: 1.6rem;
            }
        }
        @media (max-width: 576px) {
            .auth-card .p-4 {
                padding: 1.25rem !important;
            }
            .form-control {
                font-size: 0.9rem;
            }
            .btn {
                font-size: 0.9rem;
            }
        }
        /* Extra safety: ensure button is always clickable */
        .btn {
            pointer-events: auto;
            cursor: pointer;
        }
        /* No overlays – form is fully accessible */
    </style>
</head>
<body class="bg-dark">
    <!-- Navbar - responsive with toggler -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark bg-dark border-bottom border-secondary">
        <div class="container">
            <a class="navbar-brand" href="index.jsp"><i class="fas fa-graduation-cap me-2"></i>CampusConnect</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <div class="navbar-nav ms-auto">
                    <a class="nav-link" href="index.jsp">Home</a>
                    <a class="nav-link active" href="login.jsp">Login</a>
                    <a class="nav-link" href="register.jsp">Register</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Centered login form -->
    <div class="container d-flex align-items-center justify-content-center" style="min-height: calc(100vh - 72px);">
        <div class="row justify-content-center w-100">
            <div class="col-11 col-sm-8 col-md-6 col-lg-5 col-xl-4">
                <div class="card bg-dark border-secondary auth-card p-3 p-sm-4">
                    <div class="text-center mb-4">
                        <i class="fas fa-graduation-cap fa-3x text-aqua mb-2"></i>
                        <h2 class="fw-bold text-aqua">Welcome Back</h2>
                        <p class="text-secondary">Login to your account</p>
                    </div>
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <%= request.getAttribute("error") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>
                    <!-- Fixed form action: using context path for reliability -->
                    <form action="${pageContext.request.contextPath}/auth" method="post">
                        <input type="hidden" name="action" value="login">
                        <div class="mb-3">
                            <label class="form-label text-secondary">Username</label>
                            <input type="text" class="form-control bg-dark text-white border-secondary" name="username" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-secondary">Password</label>
                            <input type="password" class="form-control bg-dark text-white border-secondary" name="password" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2">Sign In</button>
                    </form>
                    <div class="text-center mt-4">
                        <p class="mb-0 text-secondary">Don't have an account? <a href="register.jsp" class="text-aqua text-decoration-none">Sign up</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>