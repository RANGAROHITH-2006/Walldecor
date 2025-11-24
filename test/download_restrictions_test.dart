import 'package:flutter_test/flutter_test.dart';
import 'package:walldecor/models/userdata_model.dart';
import 'package:walldecor/utils/download_restrictions.dart';

void main() {
  group('Download Restrictions Tests', () {
    // Helper to create a test user
    User createTestUser({
      bool isProUser = false,
      bool isTransferred = false,
      String userType = 'guest',
      int downloadCount = 0,
      String expireTime = '',
    }) {
      return User(
        id: 'test-id',
        firstName: 'Test',
        lastName: 'User',
        firebaseUserId: 'firebase-id',
        isGoogleLogin: userType == 'google',
        isAppleLogin: false,
        profileImage: null,
        favoriteImage: [],
        UserLibrary: [],
        downloadedImage: List.generate(downloadCount, (index) => 'download-$index'),
        fcmToken: [],
        userType: userType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: 'device-id',
        isRegistered: true,
        email: 'test@example.com',
        darkMode: false,
        isGuestLogin: userType == 'guest',
        feedBackGiven: false,
        isProUser: isProUser,
        isBlocked: false,
        isTransferred: isTransferred,
        isCreditEligible: false,
        expireTime: expireTime,
        autoRenew: false,
      );
    }

    test('Pro user can download unlimited images', () {
      final user = createTestUser(
        isProUser: true,
        downloadCount: 15,
        expireTime: 'Fri Dec 31 2099 23:59:59 GMT+0000'
      );
      
      expect(DownloadRestrictions.canDownload(user: user), true);
      expect(DownloadRestrictions.hasReachedLimit(user: user), false);
      expect(DownloadRestrictions.isCompletelyBlocked(user: user), false);
      expect(DownloadRestrictions.getRemainingDownloads(user: user), -1); // Unlimited
    });

    test('Transferred user is completely blocked', () {
      final user = createTestUser(
        isTransferred: true,
        downloadCount: 5,
      );
      
      expect(DownloadRestrictions.canDownload(user: user), false);
      expect(DownloadRestrictions.hasReachedLimit(user: user), true);
      expect(DownloadRestrictions.isCompletelyBlocked(user: user), true);
      expect(DownloadRestrictions.getRemainingDownloads(user: user), 0);
    });

    test('Guest user with less than 10 downloads can download', () {
      final user = createTestUser(
        userType: 'guest',
        downloadCount: 5,
        isTransferred: false,
      );
      
      expect(DownloadRestrictions.canDownload(user: user), true);
      expect(DownloadRestrictions.hasReachedLimit(user: user), false);
      expect(DownloadRestrictions.isCompletelyBlocked(user: user), false);
      expect(DownloadRestrictions.getRemainingDownloads(user: user), 5);
    });

    test('Guest user with 10 downloads has reached limit', () {
      final user = createTestUser(
        userType: 'guest',
        downloadCount: 10,
        isTransferred: false,
      );
      
      expect(DownloadRestrictions.canDownload(user: user), false);
      expect(DownloadRestrictions.hasReachedLimit(user: user), true);
      expect(DownloadRestrictions.isCompletelyBlocked(user: user), false);
      expect(DownloadRestrictions.getRemainingDownloads(user: user), 0);
    });

    test('Google non-pro user with 8 downloads can still download', () {
      final user = createTestUser(
        userType: 'google',
        isProUser: false,
        downloadCount: 8,
        isTransferred: false,
      );
      
      expect(DownloadRestrictions.canDownload(user: user), true);
      expect(DownloadRestrictions.hasReachedLimit(user: user), false);
      expect(DownloadRestrictions.isCompletelyBlocked(user: user), false);
      expect(DownloadRestrictions.getRemainingDownloads(user: user), 2);
    });

    test('Null user cannot download', () {
      expect(DownloadRestrictions.canDownload(user: null), false);
      expect(DownloadRestrictions.hasReachedLimit(user: null), true);
      expect(DownloadRestrictions.isCompletelyBlocked(user: null), true);
      expect(DownloadRestrictions.getRemainingDownloads(user: null), 0);
    });

    test('Pro user with transferred status is blocked (isTransferred takes priority)', () {
      final user = createTestUser(
        isProUser: true,
        isTransferred: true,
        downloadCount: 5,
        expireTime: 'Fri Dec 31 2099 23:59:59 GMT+0000'
      );
      
      expect(DownloadRestrictions.canDownload(user: user), false);
      expect(DownloadRestrictions.isCompletelyBlocked(user: user), true);
    });
  });
}