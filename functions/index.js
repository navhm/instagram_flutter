const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.followUser = functions.firestore.document(
    '/followers/{userId}/userFollowers/{followerId}'
).onCreate(async (_, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    //increment followed user's followers count.
    //userId is the id of the account we followed so we increase their followers.
    const followedUserRef = admin.firestore().collection('users').doc(userId);
    const followedUserDoc = await followedUserRef.get();
    if (followedUserDoc.get('followers') !== undefined) {
        followedUserRef.update({
            followers: followedUserDoc.get('followers') + 1,
        });
    }
    else {
        followedUserRef.update({
            followers: 1
        });
    }

    //increment users following count
    //follower id is the id of the account from which i followed
    const userRef = admin.firestore().collection('users').doc(followerId);
    const userDoc = await userRef.get();
    if (userDoc.get('following') !== undefined) {
        userRef.update({
            following: userDoc.get('following') + 1,
        });
    }
    else {
        userRef.update({
            following: 1
        });
    }

    //Add followed user's posts to user's post feed.
    const followedUserPostsRef = admin.firestore().collection('posts').where('author', '==', followedUserRef);

    const userFeedRef = admin.firestore().collection('feeds').doc(followerId).collection('userFeed');
    const followedUserPostsSnapshot = await followedUserPostsRef.get();
    followedUserPostsSnapshot.forEach((doc) => {
        if (doc.exists) {
            userFeedRef.doc(doc.id).set(doc.data());
        }
    });
});


exports.unfollowUser = functions.firestore.document(
    '/followers/{userId}/userFollowers/{followerId}'
).onDelete(async (_, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    //increment followed user's followers count.
    //userId is the id of the account we followed so we increase their followers.
    const followedUserRef = admin.firestore().collection('users').doc(userId);
    const followedUserDoc = await followedUserRef.get();
    if (followedUserDoc.get('followers') !== undefined) {
        followedUserRef.update({
            followers: followedUserDoc.get('followers') - 1,
        });
    }
    else {
        followedUserRef.update({
            followers: 0
        });
    }

    //increment users following count
    //follower id is the id of the account from which i followed
    const userRef = admin.firestore().collection('users').doc(followerId);
    const userDoc = await userRef.get();
    if (userDoc.get('following') !== undefined) {
        userRef.update({
            following: userDoc.get('following') - 1,
        });
    }
    else {
        userRef.update({
            following: 0
        });
    }

    //remove unfollowed users posts from the users feed

    const userFeedRef = admin.firestore().collection('feeds').doc(followerId).collection('userFeed').where('author', '==', followedUserRef);
    const userPostsSnapshot = await userFeedRef.get();

    userPostsSnapshot.forEach((doc) => {
        if (doc.exists) {
            doc.ref.delete();
        }
    })
});


exports.onCreatePost = functions.firestore.document(
    '/posts/{postId}'
).onCreate(async (snapshot, context) => {
    const postId = context.params.postId;

    //get author id
    const authorRef = snapshot.get('author');
    const authorId = authorRef.path.split('/')[1];

    //add post to feed of all followers
    const userFollowersRef = admin.firestore().collection('followers').doc(authorId).collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();

    userFollowersSnapshot.forEach((doc) => {
        admin.firestore().collection('feeds').doc(doc.id).collection('userFeed').doc(postId).set(snapshot.data);
    });
});


exports.onUpdatePost = functions.firestore.document(
    '/posts/{postId}'
).onUpdate(async (snapshot, context) => {
    const postId = context.params.postId;

    //get author id
    const authorRef = snapshot.after.get('author');
    const authorId = authorRef.path.split('/')[1];

    const updatedPostData = snapshot.after.data();  

    //update the post to feed of all the followers
    const userFollowersRef = admin.firestore().collection('followers').doc(authorId).collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    
    userFollowersSnapshot.forEach(async (doc) => {
        const postRef = admin.firestore().collection('feeds').doc(doc.id).collection('userFeed');
        const postDoc = await postRef.doc(postId).get();

        if(postDoc.exists){
            postDoc.ref.update(updatedPostData);
        }
    });
});