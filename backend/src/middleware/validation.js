const Joi = require('joi');

// Validation schemas
const schemas = {
  // User registration
  register: Joi.object({
    email: Joi.string().email().required().messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
    password: Joi.string().min(4).required().messages({
      'string.min': 'Password must be at least 4 characters long',
      'any.required': 'Password is required'
    }),
    username: Joi.string().min(3).max(30).pattern(/^[a-zA-Z0-9]+$/).required().messages({
      'string.min': 'Username must be at least 3 characters long',
      'string.max': 'Username cannot exceed 30 characters',
      'string.pattern.base': 'Username can only contain letters and numbers',
      'any.required': 'Username is required'
    }),
    profilename: Joi.string().min(2).max(100).required().messages({
      'string.min': 'Profile name must be at least 2 characters long',
      'string.max': 'Profile name cannot exceed 100 characters',
      'any.required': 'Profile name is required'
    })
  }),

  // User login
  login: Joi.object({
    email: Joi.string().email().allow(null, '').messages({
      'string.email': 'Please provide a valid email address'
    }),
    username: Joi.string().min(3).max(30).pattern(/^[a-zA-Z0-9]+$/).allow(null, '').messages({
      'string.min': 'Username must be at least 3 characters long',
      'string.max': 'Username cannot exceed 30 characters',
      'string.pattern.base': 'Username can only contain letters and numbers'
    }),
    password: Joi.string().required().messages({
      'any.required': 'Password is required'
    })
  }).custom((value, helpers) => {
    if (!value.email && !value.username) {
      return helpers.error('object.missing');
    }
    if (value.email === '') {
      delete value.email;
    }
    if (value.username === '') {
      delete value.username;
    }
    return value;
  }).messages({
    'object.missing': 'Either email or username is required'
  }),

  // User profile update
  updateProfile: Joi.object({
    profilename: Joi.string().min(2).max(50).optional().messages({
      'string.min': 'Profile name must be at least 2 characters long',
      'string.max': 'Profile name cannot exceed 50 characters'
    })
  }),

  // Watchlist item
  watchlistItem: Joi.object({
    contentid: Joi.string().required().messages({
      'any.required': 'Content ID is required'
    }),
    contenttype: Joi.string().valid('movie', 'tv').required().messages({
      'any.required': 'Content type is required',
      'any.only': 'Content type must be either movie or tv'
    }),
    title: Joi.string().required().messages({
      'any.required': 'Title is required'
    }),
    overview: Joi.string().max(1000).optional(),
    posterPath: Joi.string().uri().optional(),
    backdropPath: Joi.string().uri().optional(),
    releaseDate: Joi.date().optional(),
    voteAverage: Joi.number().min(0).max(10).optional(),
    genreIds: Joi.array().items(Joi.number()).optional(),
    priority: Joi.string().valid('low', 'medium', 'high').optional(),
    notes: Joi.string().max(500).optional(),
    tags: Joi.array().items(Joi.string()).optional()
  }),

  // Rating
  rating: Joi.object({
    contentid: Joi.string().required().messages({
      'any.required': 'Content ID is required'
    }),
    contenttype: Joi.string().valid('movie', 'tv').required().messages({
      'any.required': 'Content type is required',
      'any.only': 'Content type must be either movie or tv'
    }),
    rating: Joi.number().min(1).max(10).required().messages({
      'number.min': 'Rating must be at least 1',
      'number.max': 'Rating cannot exceed 10',
      'any.required': 'Rating is required'
    }),
    review: Joi.string().max(1000).optional(),
    title: Joi.string().max(100).optional(),
    spoiler: Joi.boolean().optional(),
    tags: Joi.array().items(Joi.string()).optional()
  }),

  // Pagination
  pagination: Joi.object({
    page: Joi.number().min(1).default(1),
    limit: Joi.number().min(1).max(100).default(20),
    sortBy: Joi.string().valid('createdAt', 'rating', 'title', 'releaseDate').default('createdAt'),
    sortOrder: Joi.string().valid('asc', 'desc').default('desc')
  }),

  // Content search
  contentSearch: Joi.object({
    query: Joi.string().min(1).required().messages({
      'string.min': 'Search query must be at least 1 character long',
      'any.required': 'Search query is required'
    }),
    type: Joi.string().valid('movie', 'tv', 'all').default('all'),
    genre: Joi.string().optional(),
    year: Joi.number().min(1900).max(new Date().getFullYear()).optional(),
    page: Joi.number().min(1).default(1)
  })
};

// Validation middleware factory
const validate = (schemaName) => {
  return (req, res, next) => {
    const schema = schemas[schemaName];
    if (!schema) {
      return res.status(500).json({ error: 'Validation schema not found' });
    }

    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errorMessages = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        error: 'Validation failed',
        details: errorMessages
      });
    }

    // Replace req.body with validated data
    req.body = value;
    next();
  };
};

// Query validation middleware
const validateQuery = (schemaName) => {
  return (req, res, next) => {
    const schema = schemas[schemaName];
    if (!schema) {
      return res.status(500).json({ error: 'Validation schema not found' });
    }

    const { error, value } = schema.validate(req.query, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errorMessages = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        error: 'Query validation failed',
        details: errorMessages
      });
    }

    // Replace req.query with validated data
    req.query = value;
    next();
  };
};

module.exports = {
  validate,
  validateQuery,
  schemas
};
