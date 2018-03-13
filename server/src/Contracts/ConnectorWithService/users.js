class RegistrationRequest {
  constructor(email, passwordData) {
    this.email = email;
    this.passwordData = passwordData;
  }
}

class UserByEmailRequest {
  constructor(email) {
    this.email = email;
  }
}

class PasswordDataRequest {
  constructor(id) {
    this.id = id;
  }
}

class UserResponse {
  constructor(id, email, nickname) {
    this.id = id;
    this.email = email;
    this.nickname = nickname;
  }
}

class PasswordDataResponse {
  constructor(hash, salt) {
    this.hash = hash;
    this.salt = salt;
  }
}

module.exports = {
  UserByEmailRequest,
  UserResponse,
  PasswordDataRequest,
  PasswordDataResponse,
  RegistrationRequest,
};