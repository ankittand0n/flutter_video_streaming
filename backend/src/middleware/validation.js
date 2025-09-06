const Joi = require('joi');

// Validation schemas
const schemas = {
  // User registration
  register: Joi.object({
    email: Joi.string().email().required().messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
    password: Joi.string().min(6).required().messages({
      'string.min': 'Password must be at least 6 characters long',
      'any.required': 'Password is required'
    }),
    username: Joi.string().min(3).max(20).alphanum().required().messages({
      'string.min': 'Username must be at least 3 characters long',
      'string.max': 'Username cannot exceed 20 characters',
      'string.alphanum': 'Username can only contain alphanumeric characters',
      'any.required': 'Username is required'
    }),
    profile: Joi.object({
      name: Joi.string().min(2).max(50).required().messages({
        'string.min': 'Name must be at least 2 characters long',
        'string.max': 'Name cannot exceed 50 characters',
        'any.required': 'Name is required'
      }),
      age: Joi.number().min(0).max(120).optional(),
      language: Joi.string().length(2).optional(),
      maturityLevel: Joi.string().valid('kids', 'teens', 'adults').optional()
    }).required()
  }),

  // User login
  login: Joi.object({
    email: Joi.string().email().required().messages({
      'string.email': 'Please provide a valid email address',
      'any.required': 'Email is required'
    }),
    password: Joi.string().required().messages({
      'any.required': 'Password is required'
    })
  }),

  // User profile update
  updateProfile: Joi.object({
    profile: Joi.object({
      name: Joi.string().min(2).max(50).optional(),
      avatar: Joi.string().uri().optional(),
      age: Joi.number().min(0).max(120).optional(),
      language: Joi.string().length(2).optional(),
      maturityLevel: Joi.string().valid('kids', 'teens', 'adults').optional()
    }).optional(),
    preferences: Joi.object({
      genres: Joi.array().items(Joi.string().valid(
        'action', 'comedy', 'drama', 'horror', 'romance', 'sci-fi', 'thriller', 'documentary', 'animation'
      )).optional(),
      contentTypes: Joi.array().items(Joi.string().valid(
        'movie', 'tv', 'documentary', 'animation'
      )).optional(),
      languages: Joi.array().items(Joi.string()).optional(),
      subtitles: Joi.boolean().optional()
    }).optional()
  }),

  // Watchlist item
  watchlistItem: Joi.object({
    contentId: Joi.string().required().messages({
      'any.required': 'Content ID is required'
    }),
    contentType: Joi.string().valid('movie', 'tv').required().messages({
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
    contentId: Joi.string().required().messages({
      'any.required': 'Content ID is required'
    }),
    contentType: Joi.string().valid('movie', 'tv').required().messages({
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
