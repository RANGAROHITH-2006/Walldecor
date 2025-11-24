import 'package:walldecor/models/userdata_model.dart';

class DownloadRestrictions {
  static const int maxDownloadLimit = 10;

  static bool canDownload({required User? user}) {
    if (user == null) return false;

    // Else if isTransferred == true → No downloads allowed (highest priority)
    if (user.isTransferred) {
      return false;
    }
    
    // If isPro == true → Unlimited downloads
    if (user.hasActiveSubscription) {
      return true;
    }
    
    // Else if (Guest or Google non-pro) → Limit to 10 downloads
    final downloadCount = user.downloadedImage.length;
    return downloadCount < maxDownloadLimit;
  }

  static bool hasReachedLimit({required User? user}) {
    if (user == null) return true;
    
    // Transferred users are always at limit (blocked) - highest priority
    if (user.isTransferred) {
      return true;
    }
    
    // Pro users never reach limit
    if (user.hasActiveSubscription) {
      return false;
    }
    
    // Check if user has reached the 10 download limit
    final downloadCount = user.downloadedImage.length;
    return downloadCount >= maxDownloadLimit;
  }

  static bool isCompletelyBlocked({required User? user}) {
    if (user == null) return true;
    
    // Only transferred users are completely blocked
    return user.isTransferred;
  }

  static int getRemainingDownloads({required User? user}) {
    if (user == null) return 0;
    
    // Transferred users get 0 regardless of pro status
    if (user.isTransferred) {
      return 0;
    }
    
    if (user.hasActiveSubscription) {
      return -1; // Unlimited
    }
    
    final downloadCount = user.downloadedImage.length;
    return maxDownloadLimit - downloadCount;
  }

  static String getBlockedMessage({required User? user}) {
    if (user == null) return 'Unable to download. Please login first.';
    
    if (user.isTransferred) {
      return 'Download functionality is not available for your account.';
    }
    
    return 'You have reached your download limit of $maxDownloadLimit images. Upgrade to Pro for unlimited downloads.';
  }
}