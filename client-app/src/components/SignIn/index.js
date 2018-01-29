import React, { Component, } from 'react';
import SignInForm from './SignInForm';
import { emailValidator, passwordValidator, } from 'src/validators';
import './styles.css';

class SignIn extends Component {
  handleSubmit(a, b, c) {
    // window.location.href = `${window.location.origin}`;
  }

  validateForm(value) {
    return {
      email: emailValidator(value.email),
      password: passwordValidator(value.password),
    };
  }

  render() {
    return (
      <div className="d-flex flex-row justify-content-center">
        <div className="content">
          <h2>Sign in</h2>
          <SignInForm
            onSubmit={this.handleSubmit}
            validator={this.validateForm}
          />
        </div>
      </div>
    );
  }
}

export default SignIn;
