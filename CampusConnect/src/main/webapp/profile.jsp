<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.User" %>
<%@ page import="com.campusconnect.model.Post" %>
<%@ page import="com.campusconnect.dao.UserDAO" %>
<%@ page import="com.campusconnect.dao.PostDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    UserDAO userDAO = new UserDAO();
    PostDAO postDAO = new PostDAO();
    int followersCount = userDAO.getFollowerCount(user.getUserId());
    int followingCount = userDAO.getFollowingCount(user.getUserId());
    List<Post> userPosts = postDAO.getPostsByUserId(user.getUserId(), user.getUserId());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Profile - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        /* responsive overrides + original styles */
        .profile-pic {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            cursor: pointer;
            transition: transform 0.2s;
            margin: 0 auto;
        }
        .profile-pic:hover {
            transform: scale(1.02);
        }
        .file-input {
            display: none;
        }
        .stats-container {
            display: flex;
            justify-content: space-around;
            margin-top: 1rem;
            gap: 1rem;
        }
        .stat-item {
            text-align: center;
        }
        .stat-item .number {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--aqua, #0dcaf0);
        }
        .stat-item .label {
            font-size: 0.8rem;
            color: var(--text-secondary, #aaa);
        }
        .post-image {
            max-width: 100%;
            border-radius: 12px;
            margin-top: 10px;
        }
        .post-item {
            background: var(--bg-card, #1e1e1e);
            transition: transform 0.2s;
        }
        .post-item:hover {
            transform: translateY(-2px);
        }
        .like-btn, .comment-btn {
            background: transparent;
            border: none;
            color: var(--text-secondary, #aaa);
            padding: 5px 12px;
            border-radius: 30px;
            transition: all 0.2s;
        }
        .like-btn:hover, .comment-btn:hover {
            background: rgba(255,255,255,0.05);
        }
        .like-btn.liked {
            color: #ff4d4d;
        }
        .delete-btn {
            background: transparent;
            border: none;
            color: #dc3545;
            padding: 5px 12px;
            border-radius: 30px;
            transition: all 0.2s;
        }
        .delete-btn:hover {
            background: rgba(220, 53, 69, 0.1);
        }
        .comment-form {
            display: flex;
            gap: 8px;
        }
        .comment-input {
            flex: 1;
            background: var(--bg-elevated, #2a2a2a);
            border: 1px solid var(--border-glow, #333);
            border-radius: 30px;
            padding: 8px 16px;
            color: white;
        }
        .comment-submit {
            background: var(--aqua, #0dcaf0);
            border: none;
            border-radius: 30px;
            padding: 0 16px;
            font-weight: bold;
            color: #000;
        }
        /* responsive media queries */
        @media (max-width: 768px) {
            .profile-pic {
                width: 100px;
                height: 100px;
            }
            .stats-container {
                gap: 0.5rem;
            }
            .stat-item .number {
                font-size: 1.2rem;
            }
            .btn {
                font-size: 0.85rem;
                padding: 0.4rem 0.8rem;
            }
            .card-body {
                padding: 1rem;
            }
        }
        @media (max-width: 576px) {
            .post-item {
                padding: 0.75rem !important;
            }
            .action-buttons {
                flex-wrap: wrap;
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
                    <a class="nav-link" href="search.jsp"><i class="fas fa-search fa-lg"></i></a>
                    <a class="nav-link" href="messages.jsp"><i class="fas fa-paper-plane fa-lg"></i></a>
                    <a class="nav-link active" href="profile.jsp"><i class="fas fa-user fa-lg"></i></a>
                    <a class="nav-link" href="auth?action=logout"><i class="fas fa-sign-out-alt fa-lg"></i></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container my-3 my-md-4">
        <!-- Alert messages -->
        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check"></i> <%= request.getParameter("success") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> <%= request.getParameter("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <div class="row g-4">
            <!-- Profile Sidebar (full width on mobile) -->
            <div class="col-12 col-md-4">
                <div class="card bg-dark border-secondary text-center p-3 p-md-4">
                    <!-- Profile photo upload form -->
                    <form action="ProfileServlet" method="post" enctype="multipart/form-data" id="photoForm">
                        <input type="hidden" name="action" value="updatePhoto">
                        <img src="<%= user.getProfilePicture() != null ? user.getProfilePicture() : "https://via.placeholder.com/150" %>" 
                             class="profile-pic mb-3" id="profileImage" onclick="document.getElementById('profilePhoto').click()">
                        <input type="file" name="profilePhoto" id="profilePhoto" class="file-input" accept="image/*" onchange="handlePhotoUpload()">
                        <br><small class="text-secondary">Click photo to upload</small>
                        <br><small class="text-secondary" id="uploadStatus"></small>
                    </form>
                    <h5 class="fw-bold text-white mt-3"><%= user.getFullName() %></h5>
                    <p class="text-secondary">@<%= user.getUserName() %></p>
                    <p class="text-secondary"><i class="fas fa-envelope me-1"></i> <%= user.getEmail() %></p>
                    <% if (user.getBio() != null && !user.getBio().isEmpty()) { %>
                        <p class="text-white-50"><i class="fas fa-quote-left me-1"></i> <%= user.getBio() %></p>
                    <% } %>
                    <div class="stats-container">
                        <div class="stat-item">
                            <div class="number"><%= userPosts.size() %></div>
                            <div class="label">Posts</div>
                        </div>
                        <div class="stat-item">
                            <div class="number"><%= followersCount %></div>
                            <div class="label">Followers</div>
                        </div>
                        <div class="stat-item">
                            <div class="number"><%= followingCount %></div>
                            <div class="label">Following</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Edit Profile + Posts -->
            <div class="col-12 col-md-8">
                <!-- Edit Profile Card -->
                <div class="card bg-dark border-secondary mb-4">
                    <div class="card-header bg-transparent border-secondary fw-bold text-aqua">
                        <i class="fas fa-edit me-2"></i>Edit Profile
                    </div>
                    <div class="card-body p-3 p-md-4">
                        <form action="ProfileServlet" method="post">
                            <input type="hidden" name="action" value="update">
                            <div class="mb-3">
                                <label class="form-label text-secondary">Full Name</label>
                                <input type="text" name="fullName" class="form-control bg-dark text-white border-secondary" 
                                       value="<%= user.getFullName() != null ? user.getFullName() : "" %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-secondary">Username</label>
                                <input type="text" name="username" class="form-control bg-dark text-white border-secondary" 
                                       value="<%= user.getUserName() != null ? user.getUserName() : "" %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-secondary">Email</label>
                                <input type="email" name="email" class="form-control bg-dark text-white border-secondary" 
                                       value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-secondary">Bio</label>
                                <textarea name="bio" class="form-control bg-dark text-white border-secondary" rows="3" placeholder="Tell us about yourself..."><%= user.getBio() != null ? user.getBio() : "" %></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Update Profile</button>
                        </form>
                    </div>
                </div>

                <!-- My Posts Card -->
                <div class="card bg-dark border-secondary">
                    <div class="card-header bg-transparent border-secondary fw-bold text-aqua">
                        <i class="fas fa-images me-2"></i>My Posts
                    </div>
                    <div class="card-body p-2 p-md-3">
                        <% if (userPosts != null && !userPosts.isEmpty()) { %>
                            <% for (Post post : userPosts) { %>
                                <div class="post-item border border-secondary rounded-3 p-3 mb-3" id="post-<%= post.getPostId() %>">
                                    <p class="post-content text-white-50"><%= post.getContent() %></p>
                                    <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { %>
                                        <img src="<%= post.getImagePath() %>" class="post-image w-100" alt="Post image">
                                    <% } %>
                                    <div class="post-actions mt-2 d-flex justify-content-between align-items-center flex-wrap">
                                        <div class="action-buttons d-flex gap-2">
                                            <button class="like-btn <%= post.isLiked() ? "liked" : "" %>" onclick="toggleLike(<%= post.getPostId() %>)" id="like-btn-<%= post.getPostId() %>">
                                                <i class="fas fa-heart"></i> <span id="like-count-<%= post.getPostId() %>"><%= post.getLikeCount() %></span>
                                            </button>
                                            <button class="comment-btn" onclick="toggleComments(<%= post.getPostId() %>)">
                                                <i class="fas fa-comment"></i> <span id="comment-count-<%= post.getPostId() %>"><%= post.getCommentcount() %></span>
                                            </button>
                                        </div>
                                        <button class="delete-btn" onclick="deletePost(<%= post.getPostId() %>)">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </div>
                                    <div class="comment-section mt-3" id="comment-section-<%= post.getPostId() %>" style="display: none;">
                                        <div class="comment-form mb-3">
                                            <input type="text" class="comment-input flex-grow-1" id="comment-input-<%= post.getPostId() %>" placeholder="Write a comment...">
                                            <button class="comment-submit" onclick="submitComment(<%= post.getPostId() %>)">Post</button>
                                        </div>
                                        <div class="comments-list" id="comments-list-<%= post.getPostId() %>"></div>
                                    </div>
                                </div>
                            <% } %>
                        <% } else { %>
                            <p class="text-secondary text-center py-4">No posts yet</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Profile photo upload
        function handlePhotoUpload() {
            const fileInput = document.getElementById('profilePhoto');
            const status = document.getElementById('uploadStatus');
            if (fileInput.files && fileInput.files[0]) {
                const file = fileInput.files[0];
                if (!file.type.startsWith('image/')) { status.innerHTML = '<span class="text-danger">Only images allowed</span>'; return; }
                if (file.size > 5 * 1024 * 1024) { status.innerHTML = '<span class="text-danger">Max 5MB</span>'; return; }
                const reader = new FileReader();
                reader.onload = function(e) { document.getElementById('profileImage').src = e.target.result; };
                reader.readAsDataURL(file);
                status.innerHTML = '<span class="text-aqua"><i class="fas fa-spinner fa-spin"></i> Uploading...</span>';
                document.getElementById('photoForm').submit();
            }
        }

        // Delete post
        function deletePost(postId) {
            if (confirm('Delete this post?')) {
                const form = document.createElement('form'); form.method = 'POST'; form.action = 'postss';
                form.innerHTML = '<input type="hidden" name="postId" value="'+postId+'"><input type="hidden" name="action" value="delete">';
                document.body.appendChild(form); form.submit();
            }
        }

        // Like / Unlike
        function toggleLike(postId) {
            const btn = document.getElementById('like-btn-'+postId);
            const cnt = document.getElementById('like-count-'+postId);
            const liked = btn.classList.contains('liked');
            if(liked) { btn.classList.remove('liked'); cnt.innerText = parseInt(cnt.innerText)-1; }
            else { btn.classList.add('liked'); cnt.innerText = parseInt(cnt.innerText)+1; }
            fetch('postss', { method:'POST', body: new URLSearchParams({ action: liked?'unlike':'like', postId }) });
        }

        // Comments
        function toggleComments(postId) {
            const sec = document.getElementById('comment-section-'+postId);
            if(sec.style.display === 'block') sec.style.display = 'none';
            else { sec.style.display = 'block'; loadComments(postId); }
        }
        function loadComments(postId) {
            const list = document.getElementById('comments-list-'+postId);
            list.innerHTML = '<div class="text-center py-3"><i class="fas fa-spinner fa-spin"></i> Loading...</div>';
            fetch('comment?action=get&postId='+postId).then(r=>r.text()).then(html=>list.innerHTML=html);
        }
        function submitComment(postId) {
            const input = document.getElementById('comment-input-'+postId);
            const content = input.value.trim();
            if(!content) return;
            const params = new URLSearchParams({ action:'create', postId, content });
            fetch('comment', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:params })
                .then(()=>{ input.value=''; loadComments(postId); 
                    const cnt = document.getElementById('comment-count-'+postId);
                    cnt.innerText = parseInt(cnt.innerText)+1;
                });
        }
        function deleteComment(commentId, postId) {
            if(!confirm('Delete comment?')) return;
            const params = new URLSearchParams({ action:'delete', commentId });
            fetch('comment', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:params })
                .then(()=>{ document.getElementById('comment-'+commentId)?.remove();
                    const cnt = document.getElementById('comment-count-'+postId);
                    cnt.innerText = Math.max(0, parseInt(cnt.innerText)-1);
                });
        }
    </script>
</body>
</html>