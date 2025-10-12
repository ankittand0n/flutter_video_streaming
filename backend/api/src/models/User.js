const prisma = require('../prisma/client');
const bcrypt = require('bcryptjs');

// Helper to parse/store JSON fields
const parseJSON = (val) => {
  if (!val) return null;
  try { return JSON.parse(val); } catch { return null; }
};

class UserModel {
  constructor(data) {
    Object.assign(this, data);
  }

  // Save (create or update)
  async save() {
    if (this.id) {
      const updated = await prisma.user.update({
        where: { id: this.id },
        data: {
          ...this._prismaWritable()
        }
      });
      Object.assign(this, updated);
      return this;
    }

    // Create
    const created = await prisma.user.create({ data: this._prismaWritable() });
    Object.assign(this, created);
    return this;
  }

  _prismaWritable() {
    return {
      email: this.email,
      password: this.password,
      username: this.username,
      profileName: this.profile?.name || this.profileName,
      profileAvatar: this.profile?.avatar || this.profileAvatar,
      profileAge: this.profile?.age || this.profileAge,
      profileLanguage: this.profile?.language || this.profileLanguage,
      profileMaturity: this.profile?.maturityLevel || this.profileMaturity,
      preferencesGenres: this.preferences?.genres ? JSON.stringify(this.preferences.genres) : this.preferencesGenres,
      preferencesTypes: this.preferences?.contentTypes ? JSON.stringify(this.preferences.contentTypes) : this.preferencesTypes,
      preferencesLangs: this.preferences?.languages ? JSON.stringify(this.preferences.languages) : this.preferencesLangs,
      preferencesSubtitles: this.preferences?.subtitles ?? this.preferencesSubtitles,
      subscriptionPlan: this.subscription?.plan || this.subscriptionPlan,
      subscriptionStatus: this.subscription?.status || this.subscriptionStatus,
      subscriptionStart: this.subscription?.startDate || this.subscriptionStart,
      subscriptionEnd: this.subscription?.endDate || this.subscriptionEnd,
      watchHistory: this.watchHistory ? JSON.stringify(this.watchHistory) : this.watchHistory,
      isActive: this.isActive,
      lastLogin: this.lastLogin,
      verificationToken: this.verificationToken,
      resetPasswordToken: this.resetPasswordToken,
      resetPasswordExpires: this.resetPasswordExpires
    };
  }

  toJSON() {
    const obj = { ...this };
    delete obj.password;
    obj._id = obj.id; // Add _id for Mongoose compatibility
    return obj;
  }

  // Mongoose-style select method (for compatibility)
  select(fields) {
    // For now, just return this (we can implement field selection later if needed)
    return this;
  }

  getPublicProfile() {
    const obj = this.toJSON();
    // build public profile similar to mongoose model
    return obj;
  }

  async comparePassword(candidate) {
    console.log('Comparing password for user:', this.username);
    const match = await bcrypt.compare(candidate, this.password);
    console.log('Password match:', match);
    return match;
  }

  // Static helpers matching Mongoose API used in routes
  static async findOne(query) {
    console.log('FindOne query:', query); // Debug log

    // support $or of email/username
    if (query.$or) {
      console.log('Processing $or query');
      for (const q of query.$or) {
        if (q.email) {
          console.log('Searching by email:', q.email);
          const u = await prisma.user.findUnique({ where: { email: q.email } });
          if (u) {
            console.log('User found by email');
            return new UserModel(u);
          }
        }
        if (q.username) {
          console.log('Searching by username:', q.username);
          const u = await prisma.user.findUnique({ where: { username: q.username } });
          if (u) {
            console.log('User found by username');
            return new UserModel(u);
          }
        }
      }
      console.log('No user found in $or query');
      return null;
    }

    if (query.email) {
      console.log('Direct email search:', query.email);
      const u = await prisma.user.findUnique({ where: { email: query.email } });
      if (u) console.log('User found by direct email');
      return u ? new UserModel(u) : null;
    }

    if (query.username) {
      console.log('Direct username search:', query.username);
      const u = await prisma.user.findUnique({ where: { username: query.username } });
      if (u) console.log('User found by direct username');
      return u ? new UserModel(u) : null;
    }

    console.log('No valid search criteria in query');
    return null;
  }

  static async findByEmail(email) {
    const u = await prisma.user.findUnique({ where: { email } });
    return u ? new UserModel(u) : null;
  }

  static async findByUsername(username) {
    const u = await prisma.user.findUnique({ where: { username } });
    return u ? new UserModel(u) : null;
  }

  static async findById(id) {
    if (!id || isNaN(Number(id))) return null;
    const u = await prisma.user.findUnique({ where: { id: Number(id) } });
    return u ? new UserModel(u) : null;
  }

  static async findByIdAndUpdate(id, updateData, opts = {}) {
    // Convert nested updates for profile and preferences
    const existing = await prisma.user.findUnique({ where: { id: Number(id) } });
    if (!existing) return null;

    const merged = {
      ...existing,
      ...updateData
    };

    // handle nested profile and preferences
    if (updateData.profile) {
      merged.profileName = updateData.profile.name || existing.profileName;
      merged.profileAvatar = updateData.profile.avatar || existing.profileAvatar;
      merged.profileAge = updateData.profile.age || existing.profileAge;
      merged.profileLanguage = updateData.profile.language || existing.profileLanguage;
      merged.profileMaturity = updateData.profile.maturityLevel || existing.profileMaturity;
    }

    if (updateData.preferences) {
      merged.preferencesGenres = updateData.preferences.genres ? JSON.stringify(updateData.preferences.genres) : existing.preferencesGenres;
      merged.preferencesTypes = updateData.preferences.contentTypes ? JSON.stringify(updateData.preferences.contentTypes) : existing.preferencesTypes;
      merged.preferencesLangs = updateData.preferences.languages ? JSON.stringify(updateData.preferences.languages) : existing.preferencesLangs;
      merged.preferencesSubtitles = updateData.preferences.subtitles ?? existing.preferencesSubtitles;
    }

    const updated = await prisma.user.update({
      where: { id: Number(id) },
      data: {
        email: merged.email,
        username: merged.username,
        profileName: merged.profileName,
        profileAvatar: merged.profileAvatar,
        profileAge: merged.profileAge,
        profileLanguage: merged.profileLanguage,
        profileMaturity: merged.profileMaturity,
        preferencesGenres: merged.preferencesGenres,
        preferencesTypes: merged.preferencesTypes,
        preferencesLangs: merged.preferencesLangs,
        preferencesSubtitles: merged.preferencesSubtitles,
        subscriptionPlan: merged.subscriptionPlan,
        subscriptionStatus: merged.subscriptionStatus,
        subscriptionStart: merged.subscriptionStart,
        subscriptionEnd: merged.subscriptionEnd,
        watchHistory: merged.watchHistory,
        isActive: merged.isActive,
        lastLogin: merged.lastLogin
      }
    });

    return new UserModel(updated);
  }

  static async findByIdAndDelete(id) {
    const deleted = await prisma.user.delete({ where: { id: Number(id) } });
    return deleted ? new UserModel(deleted) : null;
  }
}

module.exports = UserModel;
