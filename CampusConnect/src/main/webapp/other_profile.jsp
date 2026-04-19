<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.User" %>
<%@ page import="com.campusconnect.model.Post" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    User profileUser = (User) request.getAttribute("profileUser");
    List<Post> userPosts = (List<Post>) request.getAttribute("userPosts");
    Integer followersCount = (Integer) request.getAttribute("followersCount");
    Integer followingCount = (Integer) request.getAttribute("followingCount");
    Boolean isFollowing = (Boolean) request.getAttribute("isFollowing");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
    if (profileUser == null) { response.sendRedirect("search?error=User not found"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= profileUser.getFullName() %> - CampusConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        /* responsive overrides and original styling */
        .profile-pic {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            margin: 0 auto;
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
            .post-item {
                padding: 1rem !important;
            }
        }
        @media (max-width: 576px) {
            .profile-actions {
                flex-direction: column;
                gap: 0.5rem !important;
            }
            .profile-actions .btn {
                width: 100%;
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
                    <a class="nav-link" href="profile.jsp"><i class="fas fa-user fa-lg"></i></a>
                    <a class="nav-link" href="auth?action=logout"><i class="fas fa-sign-out-alt fa-lg"></i></a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container my-3 my-md-4">
        <!-- Alerts -->
        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= request.getParameter("success") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= request.getParameter("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <div class="row g-4">
            <!-- Profile Sidebar (full width on mobile) -->
            <div class="col-12 col-md-4">
                <div class="card bg-dark border-secondary text-center p-3 p-md-4">
                    <img src="<%= profileUser.getProfilePicture() != null ? profileUser.getProfilePicture() : "https://via.placeholder.com/150" %>" 
                         class="profile-pic mb-3" alt="Profile picture"
                         onerror="this.onerror=null; this.src='https://via.placeholder.com/150'">
                    <h5 class="fw-bold text-white"><%= profileUser.getFullName() %></h5>
                    <p class="text-secondary">@<%= profileUser.getUserName() %></p>
                    <p class="text-secondary"><i class="fas fa-envelope me-1"></i> <%= profileUser.getEmail() %></p>
                    <% if (profileUser.getBio() != null && !profileUser.getBio().isEmpty()) { %>
                        <p class="text-white-50"><i class="fas fa-quote-left me-1"></i> <%= profileUser.getBio() %></p>
                    <% } %>
                    <div class="profile-actions d-flex gap-2 justify-content-center mb-3 flex-wrap">
                        <button id="followBtn" class="btn <%= isFollowing ? "btn-secondary" : "btn-primary" %>" data-user-id="<%= profileUser.getUserId() %>">
                            <i class="fas fa-<%= isFollowing ? "user-check" : "user-plus" %>"></i> <span id="followText"><%= isFollowing ? "Following" : "Follow" %></span>
                        </button>
                        <a href="chat.jsp?userId=<%= profileUser.getUserId() %>" class="btn btn-success">
                            <i class="fas fa-paper-plane"></i> Message
                        </a>
                    </div>
                    <div class="stats-container">
                        <div class="stat-item">
                            <div class="number"><%= userPosts != null ? userPosts.size() : 0 %></div>
                            <div class="label">Posts</div>
                        </div>
                        <div class="stat-item">
                            <div class="number" id="followersCount"><%= followersCount != null ? followersCount : 0 %></div>
                            <div class="label">Followers</div>
                        </div>
                        <div class="stat-item">
                            <div class="number"><%= followingCount != null ? followingCount : 0 %></div>
                            <div class="label">Following</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Posts Feed (full width on mobile) -->
            <div class="col-12 col-md-8">
                <div class="card bg-dark border-secondary">
                    <div class="card-header bg-transparent border-secondary fw-bold text-aqua">
                        <i class="fas fa-images me-2"></i> <%= profileUser.getFullName() %>'s Posts
                    </div>
                    <div class="card-body p-2 p-md-3">
                        <% if (userPosts != null && !userPosts.isEmpty()) { %>
                            <% for (Post post : userPosts) { %>
                                <div class="post-item border border-secondary rounded-3 p-3 mb-3 bg-dark" id="post-<%= post.getPostId() %>">
                                    <p class="post-content text-white-50"><%= post.getContent() %></p>
                                    <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { %>
                                        <img src="<%= post.getImagePath() %>" class="post-image w-100" alt="Post image">
                                    <% } %>
                                    <div class="post-actions mt-2">
                                        <div class="action-buttons d-flex gap-2">
                                            <button class="like-btn <%= post.isLiked() ? "liked" : "" %>" onclick="toggleLike(<%= post.getPostId() %>)" id="like-btn-<%= post.getPostId() %>">
                                                <i class="fas fa-heart"></i> <span id="like-count-<%= post.getPostId() %>"><%= post.getLikeCount() %></span>
                                            </button>
                                            <button class="comment-btn" onclick="toggleComments(<%= post.getPostId() %>)">
                                                <i class="fas fa-comment"></i> <span id="comment-count-<%= post.getPostId() %>"><%= post.getCommentcount() %></span>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="comment-section mt-3" id="comment-section-<%= post.getPostId() %>" style="display: none;">
                                        <div class="comment-form mb-3">
                                            <input type="text" class="comment-input flex-grow-1" id="comment-input-<%= post.getPostId() %>" placeholder="Write a comment...">
                                            <button class="comment-submit" onclick="addComment(<%= post.getPostId() %>)">Post</button>
                                        </div>
                                        <div class="comments-list" id="comments-list-<%= post.getPostId() %>"></div>
                                    </div>
                                </div>
                            <% } %>
                        <% } else { %>
                            <p class="text-secondary text-center py-4"><%= profileUser.getFullName() %> hasn't posted anything yet</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Follow button logic (unchanged)
        document.getElementById('followBtn')?.addEventListener('click', function() {
            const btn = this;
            const targetUserId = btn.dataset.userId;
            const isFollowing = btn.classList.contains('btn-secondary');
            const action = isFollowing ? 'unfollow' : 'follow';
            const params = new URLSearchParams({ action, targetUserId });
            fetch('follow', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        if (action === 'follow') {
                            btn.classList.remove('btn-primary'); btn.classList.add('btn-secondary');
                            btn.innerHTML = '<i class="fas fa-user-check"></i> Following';
                        } else {
                            btn.classList.remove('btn-secondary'); btn.classList.add('btn-primary');
                            btn.innerHTML = '<i class="fas fa-user-plus"></i> Follow';
                        }
                        document.getElementById('followersCount').innerText = data.followerCount;
                    } else alert(data.message);
                });
        });

        // Like functionality
        function toggleLike(postId) {
            const btn = document.getElementById('like-btn-'+postId);
            const cnt = document.getElementById('like-count-'+postId);
            const liked = btn.classList.contains('liked');
            if(liked) { btn.classList.remove('liked'); cnt.innerText = parseInt(cnt.innerText)-1; }
            else { btn.classList.add('liked'); cnt.innerText = parseInt(cnt.innerText)+1; }
            fetch('postss', { method:'POST', body: new URLSearchParams({ action: liked?'unlike':'like', postId }) });
        }

        // Comments toggle and load
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
        function addComment(postId) {
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