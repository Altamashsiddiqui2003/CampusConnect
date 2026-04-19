<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusconnect.model.Comment" %>
<%@ page import="com.campusconnect.model.User" %>
<%@ page import="java.util.List" %>
<%
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    User currentUser = (User) session.getAttribute("user");
%>

<!-- custom minimal overrides – only for effects not in Bootstrap -->
<style>
    .comment-item {
        transition: all 0.2s ease;
        border-left: 3px solid transparent;
    }
    .comment-item:hover {
        transform: translateX(4px);
        border-left-color: var(--aqua, #0dcaf0);
    }
    .delete-comment-btn {
        background: transparent;
        border: none;
        color: var(--danger, #dc3545);
        font-size: 0.75rem;
        padding: 0.25rem 0.5rem;
        border-radius: 20px;
        transition: all 0.2s;
    }
    .delete-comment-btn:hover {
        background: rgba(220, 53, 69, 0.1);
    }
    .comment-fallback {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: var(--bg-elevated, #2a2a2a);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--aqua, #0dcaf0);
        font-size: 1.2rem;
        border: 1px solid var(--border-glow, rgba(0,229,255,0.2));
    }
    /* responsive avatar size */
    @media (max-width: 576px) {
        .comment-avatar, .comment-fallback {
            width: 32px !important;
            height: 32px !important;
            font-size: 1rem !important;
        }
    }
</style>

<div class="comments-container" style="max-height: 400px; overflow-y: auto;">
    <% if (comments != null && !comments.isEmpty()) {
        for (Comment comment : comments) {
            User commentUser = comment.getUser();
            String userPic = commentUser.getProfilePicture();
            boolean hasPic = userPic != null && !userPic.trim().isEmpty();
            boolean isSelf = (currentUser != null && comment.getUserId() == currentUser.getUserId());
            String profileUrl = isSelf ? "profile.jsp" : "other_profile?username=" + commentUser.getUserName();
    %>
    <!-- Bootstrap 5 card-like comment item -->
    <div class="comment-item bg-dark bg-opacity-25 rounded-3 p-2 p-sm-3 mb-3" id="comment-<%= comment.getCommentId() %>">
        <div class="d-flex gap-2 gap-sm-3">
            <!-- avatar with link -->
            <a href="<%= profileUrl %>" class="flex-shrink-0">
                <% if (hasPic) { %>
                    <img src="<%= userPic %>" class="comment-avatar rounded-circle object-fit-cover" width="40" height="40"
                         onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <div class="comment-fallback" style="display: none;"><i class="fas fa-user-circle"></i></div>
                <% } else { %>
                    <div class="comment-fallback"><i class="fas fa-user-circle"></i></div>
                <% } %>
            </a>

            <div class="flex-grow-1">
                <div class="d-flex flex-wrap justify-content-between align-items-start gap-1">
                    <div class="d-flex flex-wrap align-items-center gap-1">
                        <!-- full name -->
                        <a href="<%= profileUrl %>" class="fw-semibold text-decoration-none text-white small">
                            <%= commentUser.getFullName() %>
                        </a>
                        <!-- username -->
                        <a href="<%= profileUrl %>" class="text-secondary text-decoration-none small">
                            @<%= commentUser.getUserName() %>
                        </a>
                    </div>
                    <!-- delete button (only for own comments) -->
                    <% if (currentUser != null && comment.getUserId() == currentUser.getUserId()) { %>
                        <button class="delete-comment-btn" onclick="deleteComment(<%= comment.getCommentId() %>, <%= comment.getPostId() %>)">
                            <i class="fas fa-trash-alt"></i> <span class="d-none d-sm-inline">Delete</span>
                        </button>
                    <% } %>
                </div>

                <!-- comment content -->
                <div class="text-white-50 small mt-1">
                    <%= comment.getContent() %>
                </div>

                <!-- timestamp -->
                <div class="text-secondary-emphasis mt-2 small">
                    <i class="far fa-clock me-1"></i> <%= comment.getCreatedAt().toString().substring(0, 16) %>
                </div>
            </div>
        </div>
    </div>
    <% }
    } else { %>
    <!-- empty state – Bootstrap centered -->
    <div class="text-center py-5">
        <i class="fas fa-comment-slash fa-2x text-secondary mb-3 d-block"></i>
        <p class="text-secondary mb-0">No comments yet. Be the first to comment!</p>
    </div>
    <% } %>
</div>