<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.campusconnect.model.User, com.campusconnect.model.Post, java.util.List, java.util.ArrayList"%>
<%
User user = (User) session.getAttribute("user");
if (user == null) { response.sendRedirect("login.jsp"); return; }
List<Post> posts = (List<Post>) request.getAttribute("posts");
if (posts == null) posts = new ArrayList<>();
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
        .avatar-img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            background: var(--bg-elevated, #1e1e1e);
        }
        .avatar-fallback {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--bg-elevated, #1e1e1e);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--aqua, #0dcaf0);
            font-size: 1.2rem;
            border: 1px solid var(--border-glow, rgba(0,229,255,0.2));
        }
        .avatar-fallback.small {
            width: 32px;
            height: 32px;
            font-size: 1rem;
        }
        .post-card {
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .post-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.3);
        }
        .post-content {
            font-size: 0.95rem;
            line-height: 1.5;
            word-wrap: break-word;
        }
        .post-image, .post-video {
            max-width: 100%;
            border-radius: 12px;
            margin: 12px 0;
        }
        .action-buttons {
            display: flex;
            gap: 1rem;
        }
        .like-btn, .comment-btn {
            background: transparent;
            border: none;
            color: var(--text-secondary, #aaa);
            font-weight: 500;
            padding: 6px 12px;
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
            color: var(--text-primary, #fff);
        }
        .comment-submit {
            background: var(--aqua, #0dcaf0);
            border: none;
            border-radius: 30px;
            padding: 0 16px;
            font-weight: bold;
            color: #000;
        }
        .profile-link {
            text-decoration: none;
            color: inherit;
        }
        .profile-link:hover .fw-bold {
            color: var(--aqua);
        }
        /* Fully responsive custom file upload */
        .custom-file-upload {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(0, 229, 255, 0.1);
            border: 1px dashed var(--aqua);
            border-radius: 30px;
            padding: 8px 16px;
            cursor: pointer;
            transition: all 0.2s;
            width: 100%;
            flex-wrap: wrap;
        }
        .custom-file-upload:hover {
            background: rgba(0, 229, 255, 0.2);
            border-color: var(--aqua);
        }
        .file-name {
            font-size: 0.85rem;
            color: var(--text-secondary);
            flex: 1;
            text-align: left;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        /* On very small screens, allow filename to wrap */
        @media (max-width: 480px) {
            .custom-file-upload {
                flex-wrap: wrap;
                justify-content: center;
                gap: 6px;
            }
            .file-name {
                white-space: normal;
                text-align: center;
                width: 100%;
                flex: auto;
            }
        }
        #fileInput {
            display: none;
        }
        @media (max-width: 576px) {
            .avatar-img, .avatar-fallback {
                width: 32px !important;
                height: 32px !important;
            }
            .avatar-fallback.small {
                width: 28px !important;
                height: 28px !important;
            }
            .post-content {
                font-size: 0.85rem;
            }
            .action-buttons {
                gap: 0.5rem;
            }
            .like-btn, .comment-btn {
                padding: 4px 8px;
                font-size: 0.8rem;
            }
            .custom-file-upload {
                padding: 6px 12px;
                font-size: 0.85rem;
            }
        }
    </style>
</head>
<body class="bg-dark text-white">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark bg-dark border-bottom border-secondary">
        <div class="container">
            <a class="navbar-brand" href="home.jsp"><i class="fas fa-graduation-cap me-2"></i>CampusConnect</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <div class="navbar-nav ms-auto">
                    <a class="nav-link active" href="home.jsp"><i class="fas fa-home fa-lg"></i></a>
                    <a class="nav-link" href="search.jsp"><i class="fas fa-search fa-lg"></i></a>
                    <a class="nav-link" href="messages.jsp"><i class="fas fa-paper-plane fa-lg"></i></a>
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

    <div class="container my-3 my-md-4">
        <div class="row justify-content-center">
            <div class="col-12 col-md-8 col-lg-6">
                <!-- Welcome Card -->
                <div class="card bg-dark border-secondary mb-4">
                    <div class="card-body text-center">
                        <h4 class="text-aqua">Welcome to CampusConnect, <%= user.getFullName() %>! 👋</h4>
                        <p class="text-secondary">Share your campus experiences and connect with other students</p>
                    </div>
                </div>

                <!-- Create Post Card -->
                <div class="card border-secondary mb-4" style="background: linear-gradient(135deg, #111, #1a1a1a);">
                    <div class="card-body">
                        <h6 class="card-title text-aqua"><i class="fas fa-edit me-2"></i>Create a Post</h6>
                        <form action="postss" method="post" enctype="multipart/form-data" id="postForm">
                            <input type="hidden" name="action" value="create">
                            <textarea class="form-control bg-dark text-white border-secondary mb-3" name="content" rows="2" placeholder="What's happening on campus?"></textarea>
                            
                            <!-- Fully responsive file upload button -->
                            <div class="mb-3">
                                <label for="fileInput" class="custom-file-upload">
                                    <i class="fas fa-paperclip"></i> <span>Attach Media</span>
                                    <span id="fileNameDisplay" class="file-name">No file chosen</span>
                                </label>
                                <input type="file" id="fileInput" name="media" accept="image/*,video/*">
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100">Post</button>
                        </form>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="card bg-dark border-secondary mb-4">
                    <div class="card-body">
                        <h6 class="card-title text-aqua"><i class="fas fa-bolt me-2"></i>Quick Actions</h6>
                        <div class="d-flex flex-wrap gap-2">
                            <a href="postss?action=test" class="btn btn-success btn-sm"><i class="fas fa-plus"></i> Test Post</a>
                            <a href="search.jsp" class="btn btn-primary btn-sm"><i class="fas fa-user-plus"></i> Find Friends</a>
                            <a href="postss" class="btn btn-info btn-sm">Feeds</a>
                        </div>
                    </div>
                </div>

                <!-- Posts Feed -->
                <% if (posts.isEmpty()) { %>
                    <!-- New friendly empty state with welcome message and link to Feeds page -->
                    <div class="text-center py-5">
                        <i class="fas fa-graduation-cap fa-3x text-aqua mb-3"></i>
                        <h5 class="text-aqua">Welcome to your Campus Feed!</h5>
                        <p class="text-secondary">It looks like you haven't followed anyone yet or there are no posts.</p>
                        <p class="text-secondary">Head over to the <a href="postss" class="text-aqua text-decoration-none fw-bold">Feeds page</a> to discover posts from your campus community.</p>
                        <a href="postss" class="btn btn-outline-info mt-2">Explore Feeds <i class="fas fa-arrow-right ms-1"></i></a>
                    </div>
                <% } else { %>
                    <div class="mt-2">
                        <h5 class="text-aqua mb-3 d-flex align-items-center gap-2 flex-wrap">
                            <i class="fas fa-newspaper"></i> Campus Feed 
                            <span class="badge bg-secondary"><%= posts.size() %> posts</span>
                        </h5>
                        <% for (Post post : posts) { 
                            User postUser = post.getUser();
                            String postUserPic = postUser.getProfilePicture();
                            boolean postUserHasPic = postUserPic != null && !postUserPic.trim().isEmpty();
                            boolean isSelf = (postUser.getUserId() == user.getUserId());
                            String profileUrl = isSelf ? "profile.jsp" : "other_profile?username=" + postUser.getUserName();
                        %>
                            <div class="card post-card bg-dark border-secondary mb-4" id="post-<%= post.getPostId() %>">
                                <div class="card-body">
                                    <!-- Post header -->
                                    <div class="d-flex align-items-start gap-3 mb-3">
                                        <a href="<%= profileUrl %>" class="flex-shrink-0 profile-link">
                                            <% if (postUserHasPic) { %>
                                                <img src="<%= postUserPic %>" class="avatar-img" 
                                                     onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                <div class="avatar-fallback" style="display: none;"><i class="fas fa-user-circle"></i></div>
                                            <% } else { %>
                                                <div class="avatar-fallback"><i class="fas fa-user-circle"></i></div>
                                            <% } %>
                                        </a>
                                        <div class="flex-grow-1">
                                            <div class="d-flex flex-wrap justify-content-between align-items-start">
                                                <div>
                                                    <a href="<%= profileUrl %>" class="profile-link">
                                                        <h6 class="mb-0 fw-bold"><%= postUser.getFullName() %></h6>
                                                        <small class="text-secondary">@<%= postUser.getUserName() %></small>
                                                    </a>
                                                    <small class="text-secondary ms-2">• <%= post.getCreatedAt() %></small>
                                                </div>
                                                <% if (post.getUserId() == user.getUserId()) { %>
                                                    <form action="postss" method="post" class="ms-2">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="postId" value="<%= post.getPostId() %>">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete post?')"><i class="fas fa-trash"></i></button>
                                                    </form>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>

                                    <p class="post-content text-white-50"><%= post.getContent() %></p>
                                    <% if (post.getImagePath() != null && !post.getImagePath().isEmpty()) { %>
                                        <img src="<%= post.getImagePath() %>" class="post-image w-100" alt="Post image">
                                    <% } %>
                                    <% if (post.getVedioPath() != null && !post.getVedioPath().isEmpty()) { %>
                                        <video src="<%= post.getVedioPath() %>" class="post-video w-100" controls></video>
                                    <% } %>

                                    <div class="post-actions mt-3">
                                        <div class="action-buttons">
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
                                            <button class="comment-submit" onclick="submitComment(<%= post.getPostId() %>)">Post</button>
                                        </div>
                                        <div class="comments-list" id="comments-list-<%= post.getPostId() %>"></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // File upload preview and responsiveness
        const fileInput = document.getElementById('fileInput');
        const fileNameSpan = document.getElementById('fileNameDisplay');
        
        fileInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                fileNameSpan.textContent = file.name;
                // Optional: add file size limit warning
                if (file.size > 10 * 1024 * 1024) {
                    alert('File size exceeds 10MB. Please choose a smaller file.');
                    fileInput.value = '';
                    fileNameSpan.textContent = 'No file chosen';
                }
            } else {
                fileNameSpan.textContent = 'No file chosen';
            }
        });

        // Trigger file input when clicking custom button
        document.querySelector('.custom-file-upload').addEventListener('click', function(e) {
            // Prevent event from bubbling if needed
            e.preventDefault();
            fileInput.click();
        });

        // Like, comment functions (unchanged)
        function toggleLike(postId) {
            const btn = document.getElementById('like-btn-'+postId);
            const cnt = document.getElementById('like-count-'+postId);
            const liked = btn.classList.contains('liked');
            if(liked) { btn.classList.remove('liked'); cnt.innerText = parseInt(cnt.innerText)-1; }
            else { btn.classList.add('liked'); cnt.innerText = parseInt(cnt.innerText)+1; }
            fetch('postss', { method:'POST', body: new URLSearchParams({ action: liked?'unlike':'like', postId }) });
        }
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